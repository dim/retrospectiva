class Ticket < ActiveRecord::Base
  belongs_to :milestone
  belongs_to :status  
  belongs_to :priority
  belongs_to :project
  belongs_to :user
  belongs_to :assigned_user, :class_name => 'User'

  has_attachment :dependent => :destroy  
  has_many :changes, :class_name => 'TicketChange', 
    :order => 'ticket_changes.created_at', 
    :dependent => :destroy

  has_and_belongs_to_many :subscribers, :class_name => 'User', :join_table => 'ticket_subscribers', :uniq => true
  has_and_belongs_to_many :properties, :class_name => 'TicketProperty', :uniq => true
  
  validates_presence_of :author, :summary
  validates_length_of :content, :in => (1..50000)
  validates_association_of :status, :priority, :project

  attr_accessible :status_id, :priority_id, :milestone_id, :property_ids, :assigned_user_id 

  named_scope :for_preview, 
    :include => [{ :changes => :user }, :status, :user, :project],
    :order => 'tickets.updated_at DESC, ticket_changes.created_at'      
  
  retro_previewable do |r|
    r.channel do |c, options|
      project = options[:project] || Project.current
      c.name = 'tickets'
      c.title = _('Tickets')
      c.description = _('Tickets for %{project}', :project => project.name)
      c.link = c.route(:project_tickets_url, project)
    end
    r.item do |i, ticket, options|
      project = options[:project] || ticket.project
      i.title = _('Ticket #%{id} (%{status}) reported by %{author} - %{summary}', :id => ticket.id, :status => ticket.status.name, :author => ticket.author, :summary => ticket.summary)
      i.description = ticket.content
      i.date = ticket.created_at
      i.link = i.guid = i.route(:project_ticket_url, project, ticket)
    end
  end

  class << self
    
    def default_includes
      [ :user, :assigned_user, :subscribers ] +
      [ :status, :priority, :milestone, { :properties => :ticket_property_type } ] + 
      [ { :changes => :user }, :attachment ]
    end

    def searchable_column_names
      [ 'tickets.id', 'tickets.author', 'tickets.summary', 'tickets.content' ] + 
      [ 'ticket_changes.author', 'ticket_changes.content' ]
    end
    
    def full_text_search(query)
      filter = Retro::Search::exclusive query, *searchable_column_names
      records = for_preview.find :all, :conditions => filter, :limit => 100
      flatten_and_sort(records).reverse
    end

    def feedable
      records = for_preview.find(:all, :limit => 10)
      flatten_and_sort(records).reverse
    end

    # Override default method to include both Tickets and TicketChanges into the feed
    def to_rss(records, options = {})
      limit = options.delete(:limit) || records.size
      super(flatten_and_sort(records).last(limit).reverse)
    end

    protected
      
      def flatten_and_sort(records)
        records.map do |ticket|
          ticket.changes.map do |change| # Work-around for ActiveRecord: Make sure we don't have to query the tickets again
            change.ticket = ticket
            change
          end + [ticket]
        end.flatten.sort_by do |record|
          record.previewable(:project => record.project).date
        end
      end

  end

  def previous_ticket(filters)
    conditions = PlusFilter::Conditions.new(filters.conditions) do |c|
      c << ['tickets.updated_at < ?', updated_at]
      c << ['tickets.project_id = ?', project_id]
    end.to_a    
    self.class.find :first, 
      :conditions => conditions, 
      :include => Ticket.default_includes,
      :joins => filters.joins, 
      :order => 'tickets.updated_at DESC'
  end

  def next_ticket(filters)
    conditions = PlusFilter::Conditions.new(filters.conditions) do |c|
      c << ['tickets.updated_at > ?', updated_at]
      c << ['tickets.project_id = ?', project_id]
    end.to_a    
    self.class.find :first, 
      :conditions => conditions, 
      :include => Ticket.default_includes,
      :joins => filters.joins, 
      :order => 'tickets.updated_at ASC'
  end  

  def updated?
    !new_record? and updated_at > created_at
  end

  # Returns true if a readable attachment is assigned, else false
  def attachment?
    attachment.present? && attachment.readable?
  end
  
  # @Override: Returns the default status ID if none is assigned
  def status_id
    read_attribute(:status_id) || write_attribute(:status_id, Status.default.id)
  end

  # @Override: Returns the default priority ID if none is assigned
  def priority_id
    read_attribute(:priority_id) || write_attribute(:priority_id, Priority.default.id)
  end
  
  # Returnes a hash of properties, indexed by their type
  def property_map
    @property_map ||= properties.index_by(&:ticket_property_type)
  end

  # Assigns protected attributes on ticket-create
  def protected_attributes=(attributes = nil)
    attributes = attributes.is_a?(Hash) ? attributes.symbolize_keys : {}
    send :attributes=, attributes.only(:author, :email, :summary, :content, :attachment), false
  end

  # Updates attributes without updating the timestamps
  def update_attribute_without_timestamps(*args)
    value = self.class.record_timestamps
    self.class.record_timestamps = false
    update_attribute(*args)
  ensure
    self.class.record_timestamps = value
  end

  # Updates the updated_at attribute
  def update_timestamp(value)
    self.class.update_all ['updated_at = ?', value], ['id = ?', id]
    reload
  end
  
  # Toggles a user's subscribtion and returns the updated status (true or false)
  def toggle_subscriber(user)     
    if subscribers.include?(user)
      subscribers.delete(user) 
    elsif not user.public? and user.permitted?(:tickets, :watch, :project => project)
      subscribers << user
    end
    subscribers.include?(user)
  end
  
  # @Override: Make sure assigned properties are not saved instantly but applied after_save  
  alias_method :original_property_ids, :property_ids unless method_defined?(:original_property_ids)
  def property_ids
    new_record? || @property_ids.nil? ? original_property_ids : @property_ids
  end

  # @Override: Make sure assigned properties are not saved instantly but applied after_save  
  alias_method :original_property_ids=, :property_ids= unless method_defined?(:original_property_ids=)
  def property_ids=(value)
    if new_record?
      self.original_property_ids = value
    else
      value = [value].flatten.map(&:to_i)
      if changed_attributes.include?('property_ids') and changed_attributes['property_ids'].sort == value.sort
        changed_attributes.delete('property_ids')
      elsif property_ids.sort != value.sort
        changed_attributes['property_ids'] = property_ids.dup
      end
      @property_ids = value
    end
  end
    
  def permitted_subscribers(exclude = nil)
    exclude = nil if RetroCM[:ticketing][:subscription][:notify_author]
    subscribers.select do |user|
      not user.public? and exclude != user and user.permitted?(:tickets, :view, :project => project) and user.permitted?(:tickets, :watch, :project => project)
    end
  end

  def serialize_only
    [:id, :summary, :content, :author, :milestone_id, :created_at, :updated_at]    
  end

  def serialize_including
    [:assigned_user, :status, :priority]
  end

  protected

    # Return true if user has the permission to modify this ticket, else false
    def modifiable?(user)
      RetroCM[:ticketing][:author_modifiable][:tickets] == true && self.user == user
    end  

    def validate_on_create
      attachment.errors.each_full do |msg|
        errors.add :attachment, msg
      end if attachment and not attachment.valid?
      errors.empty?
    end
    
    def validate   
      if milestone_id and project and not project.milestones.active_on(created_at).exists?(milestone_id)
        errors.add :milestone_id,  :inclusion
      end      
      errors.empty?
    end
  
end
