class TicketChange < ActiveRecord::Base
  has_attachment :dependent => :destroy  
  belongs_to :user
  belongs_to :ticket
  
  serialize :updates, Hash
  
  attr_accessible :author, :email, :content, :attachment, *Ticket.attr_accessible 

  validates_presence_of :author
  validates_length_of :content, :maximum => 50000, :allow_blank => true
  validates_association_of :ticket

  delegate :project, :status_id, :priority_id, :milestone_id, :property_ids, :assigned_user_id, :assigned_user,
    :status_id=, :priority_id=, :milestone_id=, :property_ids=, :assigned_user_id=, :assigned_user=, 
    :status, :priority, :milestone, :status=, :priority=, :milestone=, :to => :ticket
  
  retro_previewable do |r|
    r.item do |i, change, options|
      project = options[:project] || change.project
      i.title = _('Ticket #%{id} (%{status}) changed by %{author} - %{summary}', :id => change.ticket.id, :status => change.ticket.status.name, :author => change.author, :summary => change.ticket.summary)
      
      updates = change.updates.map do |attr, update|
        "<li><strong>#{attr.humanize}:</strong> #{update[:old]} &rarr; #{update[:new]}</li>"      
      end      
      i.description = (updates.any? ? "<ul>#{updates.join}</ul> " : '') + change.content.to_s

      i.date = change.created_at
      i.link = i.guid = i.route(:project_ticket_url, project, change.ticket, :anchor => "ch#{change.id}")
    end
  end
      
  def updates?
    attachment? || updates.any?
  end
  
  def attachment?
    attachment.present? && attachment.readable?
  end
  
  def updates
    value = read_attribute :updates
    value.is_a?(Hash) ? value : {}
  end

  # Returns a hash of ticket attributes being modified since last save
  def updates_index
    return {} if ticket.nil? or !new_record?
    
    ticket.changed.inject({}) do |result, name|
      old_value, new_value = ticket.send(:attribute_change, name)
      store_changes!(result, name.to_s, old_value, new_value)
      result
    end
  end

  # Render updates as an XML array
  def to_xml(options = {}, &block)
    super do |xml|
      xml.updates :type => "array" do         
        updates.each do |attribute, update|
          xml.update do 
            xml.value attribute
            xml.old update[:old]
            xml.new update[:new]
          end
        end
      end
      yield xml if block_given?
    end
  end
  
  protected
  
    def modifiable?(user)
      RetroCM[:ticketing][:author_modifiable][:ticket_changes] == true && self.user == user
    end
  
    def validate_on_create 
      ticket.errors.each do |attr, msg|
        errors.add(attr, msg)
      end if ticket and not ticket.valid?
      
      attachment.errors.each_full do |msg|
        errors.add(:attachment, msg)
      end if attachment and not attachment.valid?

      if attachment? and content.blank?
        errors.add :content, :blank
      elsif content.blank? and not updates?
        errors.add_to_base _('No changes were made')
      end

      errors.empty?
    end
    
  private
    
    def property_names(property_ids)
      project.ticket_properties.find_all_by_id(property_ids).inject({}) do |result, property|
        result.merge property.ticket_property_type.name => property.name
      end
    end
    
    def hash_for_ticket_change(before, after)
      (before || after) && before != after ? {:old => before, :new => after} : nil
    end
    
    def store_changes!(result, name, old_value, new_value)
      send("store_changes_for_#{name}!", result, old_value, new_value)
    end
    
    def store_changes_for_property_ids!(result, old_value, new_value) 
      before, after = property_names(old_value), property_names(new_value)
      before.each do |key, value|
        change = hash_for_ticket_change(value, after.delete(key))
        result[key] = change if change
      end
      after.each do |key, value|
        change = hash_for_ticket_change(before[key], value)
        result[key] = change if change
      end      
    end      

    def store_changes_for_assigned_user_id!(result, old_value, new_value)
      before = User.find(old_value).name rescue nil
      after = User.find(new_value).name rescue nil
      change = hash_for_ticket_change(before, after)
      result[N_('Assigned user')] = change if change   
    end

    def store_changes_for_status_id!(result, old_value, new_value)
      before = Status.find(old_value).name rescue nil
      after = Status.find(new_value).name rescue nil
      change = hash_for_ticket_change(before, after)
      result[N_('Status')] = change if change
    end
      
    def store_changes_for_priority_id!(result, old_value, new_value)
      before = Priority.find(old_value).name rescue nil
      after = Priority.find(new_value).name rescue nil
      change = hash_for_ticket_change(before, after)
      result[N_('Priority')] = change if change
    end

    def store_changes_for_milestone_id!(result, old_value, new_value)
      before = project.milestones.find(old_value).name rescue nil
      after = project.milestones.find(new_value).name rescue nil
      change = hash_for_ticket_change(before, after)
      result[N_('Milestone')] = change if change
    end
  
end
