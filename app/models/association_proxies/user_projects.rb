class AssociationProxies::UserProjects < Array

  def self.instantiate(user)
    records = if user.admin?
      Project.all(:order => 'name')
    else
      user.groups.map do |group|
        group.projects
      end.flatten.uniq.sort_by(&:name)
    end
    new(records)    
  end
  
  def active
    self.class.new(select(&:active?))
  end
  
  def find(param)
    case param
    when String
      detect {|i| i.to_param == param }
    when Hash
      param.stringify_keys!
      detect {|i| i.attributes.only(*param.keys) == param }
    else
      nil
    end
  end
  
  def find!(param)
    result = find(param)
    raise ActiveRecord::RecordNotFound, "Unable to find project #{param.inspect}" unless result
    result
  end

end