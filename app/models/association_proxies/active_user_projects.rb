class AssociationProxies::ActiveUserProjects < Array

  def initialize(user)
    records = if user.admin?
      Project.find_all_by_closed(false, :order => 'name')
    else
      user.groups.map do |group|
        group.projects.select(&:active?)
      end.flatten.uniq.sort_by(&:name)
    end
    super(records)    
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