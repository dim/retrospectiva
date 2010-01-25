class Group < ActiveRecord::Base
  has_and_belongs_to_many :projects, 
    :order => 'projects.name', 
    :uniq => true
  has_and_belongs_to_many :users, 
    :order => 'users.username', 
    :uniq => true

  before_validation :normalize_permissions

  validates_length_of :name, 
    :within => 3..40
  validates_format_of :name, 
    :with => %r{^[A-Za-z0-9]+( [A-Za-z0-9]+)*$} 
  validates_uniqueness_of :name, :case_sensitive => false

  serialize :permissions, Hash

  def self.default_group
    Group.find_by_name('Default')
  end

  # Returns true if group is the Default group, else false
  def default?
    ( new_record? ? name : name_was ) == 'Default'
  end
  
  # Return true is the group has a permission for a resource, else false
  def permitted?(resource, action)
    permissions[resource.to_s].include?(action.to_s) rescue false    
  end
  
  # Returns the assigned permissions
  def permissions
    value = read_attribute(:permissions) 
    value.is_a?(Hash) ? value : {}
  end  

  # Returns a hash of nested permission-names
  def permission_names
    permissions.inject({}) do |result, (resource_name, names)|
      resource = RetroAM::permission_map[resource_name]
      next result unless resource

      labels = names.map do |name|
        resource[name] ? _(resource[name].label) : nil
      end.compact.sort
      result.merge _(resource.label) => labels
    end.sort
  end  

  # Returns the names of the associated projects, returns ['All'] if access_to_all_projects? is true
  def project_names
    access_to_all_projects? ? [_('All')] : projects.map(&:name)
  end

  def has_access_to_project?(project)
    access_to_all_projects? ? true : project_ids.include?(project.id)
  end

  protected
    
    # Normalize permissions, Examples:
    # { 'tickets' => 'view' } # =>  { 'tickets' => ['view'] }
    # { 'tickets' => ['view', 'create', '', nil] } # =>  { 'tickets' => ['create', 'view'] }
    def normalize_permissions
      permissions.each do |resource, names|
        permissions[resource] = [names].flatten.reject(&:blank?).uniq.sort
      end
    end

    def validate
      if default? && !new_record? && name_changed?
        errors.add_to_base _('Default group cannot be modified.')
      end
      if !default? && permissions.values.flatten.reject(&:blank?).blank?
        errors.add :permissions, :must_be_specified
      end
      errors.empty?
    end
    
    def before_destroy
      if default?
        errors.add_to_base _('Default group cannot be deleted')
      end
      errors.empty?
    end

end
