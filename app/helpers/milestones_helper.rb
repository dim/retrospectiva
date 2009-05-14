module MilestonesHelper

  def links_to_edit_and_delete(milestone)
    links = []
    if permitted?(:milestones, :update)
      links << link_to(_('Edit'), edit_project_milestone_path(Project.current, milestone))
    end  
    if permitted?(:milestones, :delete)
      link = link_to _('Delete'), project_milestone_path(Project.current, milestone), options_for_destroy_link
      links << link
    end  
    links.empty? ? nil : "<div class=\"top-1\">#{links.join(' | ')}</div>"
  end
  
  def ticket_stats_and_links(milestone)
    Status.states.reverse.map do |state|
      count = milestone.ticket_counts[state.type]
      next nil if count.zero?
      
      link_to _(state.group) + " (#{count})", project_tickets_path(Project.current, :state => state.id, :milestone => milestone.id)
    end.compact.join(', ')
  end
  
  def progress_bars(milestone)
    Status.states.reverse.map do |state|
      percentage = milestone.progress_percentages[state.type]
      next nil if percentage.zero?

      content_tag :div, image_spacer(:size => '1x14'), 
        :class => state.type.to_s.dasherize,
        :style => "width:#{number_to_percentage percentage, :precision => 0};"
    end.compact.join
  end

end
