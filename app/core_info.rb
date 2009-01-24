#--
# Copyright (C) 2008 Dimitrij Denissenko
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
    tickets.permission :modify, :label => N_('Modify') do |user, *records|
      [records].flatten.compact.map do |record|
        record.modifiable?(user)
      end.uniq == [true]
    end
    tickets.permission :watch, :label => N_('Watch')
  end

  # Default resource
  map.resource :content, :label => N_('Content') do |content|
    content.permission :search, :label => N_('Search')
  end
  
end
