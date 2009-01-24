class AssociationProxies::ProjectUsers

  def initialize(project)
    @project = project    
  end

  def with_permission(resource, action)
    records.select do |user|
      user.permitted?(resource, action, :project => @project)
    end
  end  

  def find(what, options = {})
    conditions = PlusFilter::Conditions.new do |c|
      c << ['users.username <> ?', 'Public']
      c << ['( users.admin = ? OR projects.id = ? )', true, @project.id]
      c << options[:conditions]
    end

    User.find what,
      :include => {:groups => :projects},
      :conditions => conditions.to_a,
      :order => 'LOWER(users.name) ASC'
  end

  protected
  
    def records
      loaded? ? @records : @records = find(:all)
    end

    def loaded?
      not @records.nil?
    end


end

