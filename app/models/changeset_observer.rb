#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class ChangesetObserver < ActiveRecord::Observer

  def before_create(changeset)
    changeset.user = User.find_by_scm_name_and_active(changeset.author, true)
    true
  end
  
  # Make sure the Changeset-Project relations are in sync
  def after_create(changeset)
    Changeset.update_project_associations! unless changeset.skip_project_synchronization     
    true
  end
  
end
