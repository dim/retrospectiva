#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
RetroAM.permission_map do |map|

  permitted_and_non_public = lambda { |project, user, has_permission, *records|
      has_permission and not user.public?
  }

  map.resource :goals, :label => N_('Goals') do |stories|
    stories.permission :view,   :label => N_('View')
    stories.permission :create, :label => N_('Create')
    stories.permission :update, :label => N_('Update')
    stories.permission :delete, :label => N_('Delete')
  end

  map.resource :sprints, :label => N_('Sprints') do |sprints|
    sprints.permission :create, :label => N_('Create')
    sprints.permission :update, :label => N_('Update')
    sprints.permission :delete, :label => N_('Delete')
  end

  map.resource :stories, :label => N_('Stories') do |stories|
    stories.permission :view,   :label => N_('View')
    stories.permission :create, :label => N_('Create'), &permitted_and_non_public
    stories.permission :update, :label => N_('Update'), &permitted_and_non_public
    stories.permission :delete, :label => N_('Delete')
    stories.permission :modify, :label => N_('Modify'), &permitted_and_non_public
  end

end
