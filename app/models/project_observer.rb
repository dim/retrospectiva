#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class ProjectObserver < ActiveRecord::Observer

  # * Create/Update short name
  # * Normalize project_root
  def before_validation(project)
    project.short_name = project.name.to_s.to_web_safe_name
    project.normalize_root_path!
    project.locale = nil if project.locale.blank?
    true
  end

  # * Make the project accessible for 'Default' user group
  # * Assign project to all groups with global project access
  # * Reset the 'central' status of all other projects if this project is 'central'
  def before_create(project)
    project.groups << Group.default_group
    project.groups << Group.find_all_by_access_to_all_projects(true)
    if project.central?
      project.class.update_all ['central = ?', false] 
    end
    true 
  end

  def before_save(project)
    if project.central?
      project.class.central = project
    end
    true 
  end

  # * Reset the 'central' status of all other projects if this project is 'central'
  def before_update(project)
    if project.central?
      project.class.update_all ['central = ?', false], ['id <> ?', project.id]
    end
    true 
  end

  # Update changeset associations
  def after_create(project)
    if project.active?
      Changeset.update_project_associations!
    end
    true
  end
  
  # * Drop changeset associations if the project is closed
  # * Renew changeset associations if project is open and the path has changed
  # * Renew changeset associations if project is open and was closed before
  def after_update(project)
    if project.closed?
      project.changesets.clear
    elsif project.active? and (project.closed_was or project.root_path_changed? or project.repository_id_changed?)
      project.changesets.clear      
      Changeset.update_project_associations!
    end
    true
  end
  
end