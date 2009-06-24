class Project < ActiveRecord::Base
  has_and_belongs_to_many :groups, :uniq => true
  has_and_belongs_to_many :changesets, :uniq => true  
  has_many :tickets, :dependent => :destroy  
  has_many :ticket_changes, :through => :tickets, :source => :changes
  has_many :milestones, :dependent => :destroy
  has_many :ticket_property_types, :dependent => :destroy
  has_many :ticket_properties, :through => :ticket_property_types
  has_many :ticket_reports, :dependent => :destroy
  belongs_to :repository

  FN_PATTERN = '[~\#\-!\w\.\+]'

  validates_length_of :name, :in => 2..80
  validates_uniqueness_of :name, :case_sensitive => false
  validates_format_of :name, 
    :with => /^[A-Za-z]/ 
  validates_format_of :root_path, 
    :with => %r{^(#{FN_PATTERN}+([ /]#{FN_PATTERN}+)*)?/$},
    :allow_nil => true
    
  validates_inclusion_of :locale, 
    :in => RetroI18n.locales.map(&:code), 
    :allow_nil => true
  validates_length_of :info, :maximum => 50000, :allow_blank => true

  serialize :existing_tickets, Hash
  serialize :existing_revisions, Array
  serialize :enabled_modules, Array
  
  attr_accessor :path_to_first_menu_item

  named_scope :active, :conditions => ['projects.closed = ?', false]
  named_scope :central, :conditions => ['projects.central = ?', true]

  class << self
    
    def current=(project)
      @current_project = project
    end
    
    def current
      @current_project.is_a?(Project) ? @current_project : nil
    end    

    def central=(project)
      @central_project = nil
    end

    def central
      if @central_project.nil?
        @central_project = Project.active.central.find(:first) || false  
      end
      @central_project
    end

    # Fixed Rails development mode bug (http://rails.lighthouseapp.com/projects/8994/tickets/1339) 
    def skip_time_zone_conversion_for_attributes
      []
    end

  end

  def to_param
    short_name  
  end

  # Override for AR's default inspect method
  def inspect
    attributes_as_nice_string = self.class.column_names.collect do |name|
      if ( has_attribute?(name) || new_record? )
        value = self.class.serialized_attributes.key?(name) ? "[#{self.class.serialized_attributes[name]}]" : attribute_for_inspect(name)
        "#{name}: #{value}"
      end
    end.compact.join(", ")
    "#<#{self.class} #{attributes_as_nice_string}>"
  end
  
  def active?
    not closed?
  end

  def existing_tickets
    value = read_attribute(:existing_tickets)
    value.is_a?(Hash) ? value : {}
  end

  def reset_existing_tickets!
    self.existing_tickets = tickets.inject({}) do |result, ticket|
      result[ticket.id] = { :state => ticket.status.state_id, :summary => ticket.summary } if ticket.status
      result
    end
    save
  end

  def existing_revisions
    value = read_attribute(:existing_revisions)
    value.is_a?(Array) ? value : []
  end
  
  def reset_existing_revisions!
    self.existing_revisions = changesets.map(&:revision)
    save
  end  

  def enabled_modules
    value = read_attribute(:enabled_modules)
    value.is_a?(Array) ? value : []
  end
  
  # Returns a sorted list of enabled menu items
  def enabled_menu_items
    RetroAM.sorted_menu_items(enabled_modules)
  end
  
  # Normalizes the root_path
  def normalize_root_path!
    path = (root_path || '').strip.gsub(/\/+$/, '').gsub(/^\/+/, '')    
    self.root_path = path.blank? ? nil : path + '/'    
  end

  # Returns the path relative to the project's root path
  def relativize_path(path)
    path.to_s.gsub(/^\/?#{Regexp.escape(root_path.to_s)}\/?/, '')
  end
  
  # Returns the absolute path of a node, by prefixing the project's root path
  def absolutize_path(path = nil)
    "#{root_path}#{path}"
  end

  # Returns all the users who are permitted to access this project
  def users
    @users ||= AssociationProxies::ProjectUsers.new(self)
  end

  def active_repository?
    repository.present? and repository.active?
  end
  
  def identifier
    short_name
  end

  def serialize_only
    [:name, :info, :locale, :central]
  end

  def serialize_methods
    [:identifier]
  end
  
  protected

    def validate
      errors.add :name, :overlap if name_overlap? 
      errors.add :central, :cannot_be_selected if central? and closed? 
      true
    end

  private
  
    # Returns true if another project already uses the same short_name
    def name_overlap?
      conditions = ['short_name = ?', short_name]
      unless new_record?
        conditions.first << ' AND id <> ?'
        conditions << id
      end      
      self.class.exists?(conditions)    
    end
  
end
