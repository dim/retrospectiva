module MilestonesHelper

  def links_to_edit_and_delete(milestone)
    links = []
    if User.current.permitted?(:milestones, :edit)
      links << link_to(_('Edit'), edit_project_milestone_path(Project.current, milestone))
    end  
    if User.current.permitted?(:milestones, :delete)
      link = link_to _('Delete'), 
        project_milestone_path(Project.current, milestone),
        :confirm => _('Really delete this milestone record?'),
        :method => :delete
      links << link
    end  
    links.empty? ? nil : "<div class=\"top-1\">#{links.join(' | ')}</div>"
  end

end
