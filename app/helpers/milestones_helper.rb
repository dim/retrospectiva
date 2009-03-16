module MilestonesHelper

  def links_to_edit_and_delete(milestone)
    links = []
    if permitted?(:milestones, :edit)
      links << link_to(_('Edit'), edit_project_milestone_path(Project.current, milestone))
    end  
    if permitted?(:milestones, :delete)
      link = link_to _('Delete'), 
        project_milestone_path(Project.current, milestone),
        :confirm => _('Really delete this milestone record?'),
        :method => :delete
      links << link
    end  
    links.empty? ? nil : "<div class=\"top-1\">#{links.join(' | ')}</div>"
  end
  
  def ticket_stats_and_links(milestone)
    [[1, milestone.open_tickets, _('Open')],
     [2, milestone.in_progress_tickets, _('In progress')],
     [3, milestone.closed_tickets, _('Closed')]
    ].map do |state_id, count, label|
      next nil if count.zero?
      link_to "#{label} (#{count})", :controller => 'tickets', :state => state_id, :milestone => milestone.id
    end.compact.join(', ')
  end

end
