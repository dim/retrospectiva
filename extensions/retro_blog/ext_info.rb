#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
RetroAM.permission_map do |map|

  map.resource :blog_posts, :label => N_('Blog Posts') do |posts|
    posts.permission :view,   :label => N_('View')
    posts.permission :create, :label => N_('Create') do |project, user, has_permission, *records|
      has_permission and not user.public?
    end
    posts.permission :update, :label => N_('Update')
    posts.permission :comment, :label => N_('Comment')
    posts.permission :delete, :label => N_('Delete')
  end
    
end
