#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
module StoriesHelper
  include AgilePmHelper

  def current_view
    @current_view ||= if action_name == 'backlog'
      :backlog
    elsif action_name == 'index' && ['pending', 'completed'].include?(params[:show])
      params[:show].to_sym
    elsif action_name == 'index'
      :active
    else
      nil
    end
  end
  
  def current_view?(name)
    current_view == name
  end

  def link_to_sprint(milestone, sprint, active = false)    
    path = project_milestone_sprint_stories_path(Project.current, milestone, sprint)
    name = h(truncate(sprint.title))
    link_to_unless active, name, path, :class => 'apm-nav-link' do 
      "<span class=\"apm-nav-link\">#{name}</span>"
    end
  end

  def sprints_navigation(milestone)
    milestone.sprints.map do |sprint|
      link_to_unless_current h(sprint.title), backlog_project_milestone_sprint_stories_path(Project.current, milestone, sprint)
    end.join(' | ')    
  end

  def story_status(story)
    if story.pending?
      _('Pending')
    elsif story.completed?
      _('Completed on %{date}', :date => date_format(story.completed_at.to_date)) + ' - ' + 
      _('%{period} ago', :period => time_ago_in_words(story.completed_at))
    else
      _('Started on %{date}', :date => date_format(story.started_at.to_date)) + ' - ' +
      _('%{period} ago', :period => time_ago_in_words(story.started_at))
    end
  end

  def story_actions(story)
    return [] unless permitted?(:stories, :update)
    
    links = []
    if story.orphanned? or ( story.in_progress? and !story.assigned_to?(User.current) )
      links << link_to(_('Take Over'), accept_story_path(story), 
        :method => :put,
        :confirm => _('Are you sure?'))
    elsif story.in_progress? and story.assigned_to?(User.current)
      links << link_to(_('Finish'), complete_story_path(story), 
        :method => :put,
        :confirm => _('Are you sure?'))
    elsif story.pending?
      links << link_to(_('Start'), accept_story_path(story), 
        :method => :put, 
        :confirm => _('Are you sure?') + ' ' + _("You cannot put it back!"))
    elsif story.completed?
      links << link_to(_('Re-open'), reopen_story_path(story), 
        :method => :put,
        :confirm => _('Are you sure?'))
    end
    
    links
  end
  
  def completed_status(story)
    value = number_to_percentage(story.percent_completed, :precision => 0)    
    
    if permitted?(:stories, :update) and story.in_progress? and story.assigned_to?(User.current)
      link_to_function(value, '', :id => "story_#{story.id}_progress") + 
        in_place_editor_for_process(story)
    else
      value 
    end
  end

  def hours_comparison(story)    
    revision   = _('%{count}h', :count => story.revised_hours)
    estimation = _('%{count}h', :count => story.estimated_hours)

    if permitted?(:stories, :update) and not story.completed?
      link_to_function(revision, '', :id => "story_#{story.id}_hours") +
        in_place_editor_for_hours(story)
    else
      revision 
    end + " (#{estimation})"
  end
  
  def plus_chart(element_id, total, *lines)
    javascript_tag "new PlusChart.Stack('#{element_id}', #{total}, #{lines.to_json});"
  end

  private   
    
    def enkode_token_tag(text)
      text
    end

    def in_place_editor_for_process(story)
      collection = (0..10).map {|i| [i*10, "#{i*10}%"] }.reverse
      in_place_editor_for_story 'Ajax.InPlaceCollectionEditor', "story_#{story.id}_progress", 
        { :url => update_progress_story_path(story, :format => :js) },
        { :collection => collection.to_json, 
          :value => story.percent_completed,
          :onComplete => "function(tp, el) { this.options.value = this.element.innerHTML.gsub(/\\D/, '') }"
        }
    end
  
    def in_place_editor_for_hours(story)
      in_place_editor_for_story 'Ajax.RetroInPlaceEditor', "story_#{story.id}_hours", 
        { :url => revise_hours_story_path(story, :format => :js) },
        { :text => story.revised_hours, 
          :onComplete => "function(tp, el) { this.options.text = this.element.innerHTML.gsub(/\\D/, '') }"
        }
    end

    def in_place_editor_for_story(klass, element_id, url_options, js_options)
      in_place_editor klass, element_id, url_options, js_options.reverse_merge(
        :ajaxOptions => "{method:'put'}",
        :okControl => 'link'.to_json,
        :onEnterHover => 'null',
        :onFormCustomization => %Q(
          function(ipe, form) {
            form.appendChild(document.createElement('br'));
          }
        ).squish,
        :htmlResponse => 'false',
        :onComplete => 'null',
        :onLeaveHover => 'null' 
      )      
    end

end
