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
    # Make sure the Changeset-Project relations are in sync
    Changeset.update_project_associations! unless changeset.skip_project_synchronization     

    # Update existing-revisions cache for all projects
    changeset.projects.each do |project|
      project.update_attribute :existing_revisions, (project.existing_revisions + [changeset.revision]).uniq
    end
  end

  def before_destroy(changeset)
    # Update existing-revisions cache for all projects
    changeset.projects.each do |project|
      project.update_attribute :existing_revisions, (project.existing_revisions - [changeset.revision]).uniq
    end
  end
  
end
