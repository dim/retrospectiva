#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class ChangesetObserver < ActiveRecord::Observer

  def before_create(changeset)
    changeset.user = User.active.find_by_scm_name changeset.author
    true
  end
  
  def after_create(changeset)
    unless changeset.bulk_synchronization

      # Create changeset-project relations
      relevant_paths = changeset.changes.map do |change|
        [change.path, change.from_path].compact
      end.flatten

      changeset.projects = changeset.repository.projects.select do |project|
        project.root_path.nil? || relevant_paths.find {|path| path.starts_with?(project.root_path) }
      end
  
      # Update existing-revisions cache for all projects
      changeset.projects.each do |project|
        project.update_attribute :existing_revisions, (project.existing_revisions + [changeset.revision]).uniq
      end
    end    
  end

  def before_destroy(changeset)
    # Update existing-revisions cache for all projects
    changeset.projects.each do |project|
      project.update_attribute :existing_revisions, (project.existing_revisions - [changeset.revision]).uniq
    end
  end
  
end
