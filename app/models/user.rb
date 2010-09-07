class User < ActiveRecord::Base
  has_and_belongs_to_many :groups, 
    :order => 'groups.name',
    :uniq => true

  has_many :changesets, :dependent => :nullify
  has_many :assigned_tickets, 
    :class_name => 'Ticket', 
    :foreign_key => 'assigned_user_id',
    :dependent => :nullify
  has_many :tickets, :dependent => :nullify
  has_many :ticket_changes, :dependent => :nullify
  has_many :login_tokens, :dependent => :destroy
  

  validates_uniqueness_of :username, :allow_blank => true, :case_sensitive => false
  validates_length_of     :username, :within => 3..40
  validates_format_of     :username, :with => /^[^\s]+$/

  validates_presence_of   :name, :email, :unless => :public?
  validates_uniqueness_of :email, :allow_blank => true, :case_sensitive => false, :unless => :public?
  validates_as_email :email, :allow_blank => true

  validates_confirmation_of :plain_password

  validates_presence_of :plain_password, :on => :create
  validates_length_of :plain_password, :within => 6..40, :on => :create, :allow_blank => true

  validates_uniqueness_of :scm_name, :case_sensitive => false, :allow_blank => true
  validates_inclusion_of :time_zone, :in => ActiveSupport::TimeZone::MAPPING.keys

  attr_accessible :name, :plain_password, :plain_password_confirmation, :time_zone
  attr_accessor_with_default :plain_password, ''
  attr_accessor_with_default :plain_password_confirmation, ''
  
  named_scope :active, :conditions => ['active = ?', true]
  
  class << self

    def current=(user)
      @current_user = user
    end
    
    def current
      @current_user.is_a?(User) ? @current_user : public_user
    end
    
    def public_user
      User.find_by_username 'Public', :include => {:groups => :projects}
    end

    def searchable_column_names
      ['username', 'name', 'email', 'scm_name'].map do |name|
        "#{quoted_table_name}.#{name}"
      end
    end
    
    def authenticate(params)
      user = params.is_a?(Hash) ? identify(params[:username]) : nil
      if user
        success = if secure_auth? 
          user.valid_password_hash?(params[:hash], params[:tan])
        else
          user.valid_password?(params[:password])
        end
        return user if success
      end     
      nil
    end  

    # Returns an active user for given username or email address
    def identify(username_or_email)
      return nil if username_or_email.blank? or username_or_email == 'Public'
      
      if username_or_email =~ /@/ 
        active.find_by_email(username_or_email)
      else
        active.find_by_username(username_or_email)
      end      
    end

    def per_page
      10
    end
    
    protected
      
      def secure_auth?
        RetroCM[:general][:user_management][:secure_auth]
      end

  end

  # Returns true is user is the currently logged-in user, else false
  def current?
    self == User.current
  end
 
  # Returns true is user is the public user, else false
  def public?
    ( new_record? ? username : username_was ) == 'Public'
  end

  # Returns true is user is the last available administrator
  def last_admin?
    admin_was && self.class.count(:all, :conditions => { :admin => true }) == 1
  end
  
  # Returns true if given plain password matches, else false
  def valid_password?(plain)
    password == hash_crypt(plain.to_s)    
  end
  
  # Returns true if given hash digest matches the plain password for a given tan
  def valid_password_hash?(hash, token = nil)    
    Digest::SHA1.hexdigest("#{SecureToken.spend(token)}:#{password}") == hash    
  end

  # Returns all projects available for the user
  def projects
    @projects ||= AssociationProxies::UserProjects.instantiate(self)
  end

  # Resets the password attribute, expects plain password
  def reset_password(plain)
    self.password = hash_crypt(plain)
  end

  # Returns the salt attribute, resets it automatically if blank
  def salt
    read_attribute(:salt) || reset_salt
  end
  
  # Returns the activation_code attribute, resets it automatically if blank
  def activation_code
    read_attribute(:activation_code) || reset_activation_code
  end

  # Returns the private_key attribute, resets it automatically if blank
  def private_key
    read_attribute(:private_key) || reset_private_key
  end

  # Resets user's salt
  def reset_salt
    self.salt = Randomizer.string
  end

  # Resets user's activation code
  def reset_activation_code
    self.activation_code = Randomizer.pronounceable
  end
  
  # Resets user's private key
  def reset_private_key
    self.private_key = ActiveSupport::SecureRandom.hex(32)
  end
  
  def has_access?(path_or_hash, method = :get)
    path_or_hash = path_or_hash.dup
    path = path_or_hash.is_a?(Hash) ? ActionController::Routing::Routes.generate(path_or_hash) : path_or_hash
    path.sub!(%r/^#{Regexp.escape(ActionController::Base.relative_url_root.to_s)}/, '')  # Remove URL prefix
    path.sub!(/\?.+?$/, '') # Remove query string
    options = ActionController::Routing::Routes.recognize_path(path, :method => method)

    controller = "#{options[:controller].camelize}Controller".constantize
    action = options[:action] ? options[:action].to_s : 'index'
    project = options[:project_id] ? Project.find_by_short_name(options[:project_id]) : Project.current
    controller.authorize?(action, options, self, project)
  end 
  
  def permitted?(resource, action, *args)
    return false unless active?
    return true if admin?
    
    options    = args.extract_options!
    project    = options[:project] || Project.current
    permission = RetroAM.permission_map.find(resource, action)
    
    if project && permission
      has_permission = project_permission?(project, resource, action)
      permission.custom? ? permission.evaluate(project, self, has_permission, *args) : has_permission
    else
      false
    end
  end

  def serialize_only
    [:id, :username, :name]
  end

  protected

    class PermissionSet < Hash

      def union(permissions)        
        permissions.each do |ressource, names|
          self[ressource] ||= []
          self[ressource] = (self[ressource] + names).reject(&:blank?).uniq.sort
        end
        self
      end

    end

    def project_permissions(project)
      return {} unless project

      @cached_permissions ||= {}
      @cached_permissions[project.id] ||= groups.inject(PermissionSet.new) do |result, group|
        result.union(group.permissions) if group.has_access_to_project?(project)
        result
      end
    end

    def project_permission?(project, resource, action)
      project_permissions(project)[resource.to_s].include?(action.to_s) rescue false
    end

    def rollback_changes!
      changed_attributes.each { |attr, value_was| self[attr] = value_was }      
    end

    def validate
      if public? && admin?
        errors.add :admin, :not_for_public
      end
      if !admin? && last_admin?
        errors.add :admin, :last_available
      end
      if current? && admin_was && !admin?
        errors.add :admin, :invalid_downgrade
      end
      if public? && !active?
        errors.add :active, :must_be_active
      end
      if current? && active_was && !active?
        errors.add :active, :own_account_must_be_active
      end
      if public? && changed? && !new_record?
        errors.add_to_base _('Public user cannot be modified.')
        rollback_changes!
      end
      errors.empty?
    end

    # Make sure user is:
    # * NOT the Public use
    # * NOT the last admin
    # * NOT the currently logged-in user
    def before_destroy
      if public?
        errors.add_to_base _('Public user cannot be deleted.')
      end
      if last_admin?
        errors.add_to_base _("Cannot delete. User '%{username}' is the last available admin.", :username => username)
      end
      if current?
        errors.add_to_base _('You cannot delete your own account.')
      end
      errors.empty?
    end

    def hash_crypt(plain)
      Digest::SHA1.hexdigest("+++{{#{plain}:#{salt}}}---")
    end
end
