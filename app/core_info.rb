#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
RetroAM.permission_map do |map|

  map.resource :changesets, :label => N_('Changesets') do |changesets|
    changesets.permission :view, :label => N_('View')
  end
  
  map.resource :code, :label => N_('Code') do |code|
    code.permission :browse, :label => N_('Browse')
  end

  map.resource :milestones, :label => N_('Milestones') do |milestones|
    milestones.permission :view, :label => N_('View')
    milestones.permission :create, :label => N_('Create')
    milestones.permission :update, :label => N_('Update')
    milestones.permission :delete, :label => N_('Delete')
  end

  map.resource :tickets, :label => N_('Tickets') do |tickets|
    tickets.permission :view, :label => N_('View')
    tickets.permission :create, :label => N_('Create')
    tickets.permission :update, :label => N_('Update')
    tickets.permission :delete, :label => N_('Delete')    
    tickets.permission :watch, :label => N_('Watch') do |project, user, has_permission, *records|
      has_permission and not user.public?
    end
    tickets.permission :modify, :label => N_('Modify') do |project, user, has_permission, *records|
      has_permission or  
        [records].flatten.compact.find do |record|
          not record.send(:modifiable?, user)
        end.blank?
    end    
  end

  map.resource :reports, :label => N_('Reports') do |reports|
    reports.permission :create, :label => N_('Create')
    reports.permission :delete, :label => N_('Delete')
  end

  # Default resource
  map.resource :content, :label => N_('Content') do |content|
    content.permission :search, :label => N_('Search')
  end
  
end
