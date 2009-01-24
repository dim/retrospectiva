#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class GroupObserver < ActiveRecord::Observer

  def before_save(group)
    if group.access_to_all_projects?
      group.projects = Project.find(:all)
    end
    true
  end  

end