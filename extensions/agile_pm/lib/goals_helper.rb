#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
module GoalsHelper
  include AgilePmHelper
  
  def render_sprint_table(sprint)
    return sprint.map do |s|
      render_sprint_table(s)
    end.join("\n") if sprint.is_a?(Array)
    
    info = [date_format(sprint.starts_on), date_format(sprint.finishes_on)]    
    render :partial => 'sprint', :locals => {
      :sprint => sprint,
      :sprint_dom_id => sprint.title.parameterize,
      :title  => h(sprint.title),
      :sprint_info => info.join(' &ndash; ')
    }    
  end
  
  def render_unassigned_table
    render :partial => 'sprint', :locals => {
      :sprint => nil,
      :sprint_dom_id => 'unassigned',
      :title  => _('Unassigned'),
      :sprint_info => '&nbsp;'
    }        
  end
  
  def sprint_management_links(sprint)
    return '' if sprint.blank?
    
    content = []
    content << link_to(_('Edit'), edit_sprint_path(sprint)) if permitted?(:sprints, :edit)
    content << link_to(_('Delete'), sprint_path(sprint), options_for_destroy_link) if permitted?(:sprints, :delete)
    return '' if content.empty?
    
    "<span class=\"small\">(#{content.join(' | ')})</span>"
  end
  
  def link_to_milestone(milestone, active = false)
    path = project_milestone_goals_path(Project.current, milestone)
    name = h(truncate(milestone.name))
    link_to_unless active, name, path, :class => 'apm-nav-link' do 
      "<span class=\"apm-nav-link\">#{name}</span>"
    end
  end
  
  def hide_all_show_one(sprint_dom_id)
    %Q(
      $$('.sprint-details').each(Element.hide); 
      $('#{sprint_dom_id}').show();
      window.location.hash = '##{sprint_dom_id}'; 
    ).squish
  end

  def hide_all_show_current(sprint)
    sprint_dom_id = sprint ? sprint.title.parameterize : 'unassigned'
    %Q(
      $$('.sprint-details').each(Element.hide);
      var h = $(window.location.hash.gsub(/#/, ''));
      h ? h.show() : $('#{sprint_dom_id}').show();
    ).squish
  end
  
end
