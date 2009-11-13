#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
module AgilePmHelper
  
  def goals_path(*args)
    project_milestone_goals_path(Project.current, @milestone, *args)  
  end

  def goal_path(*args)
    project_milestone_goal_path(Project.current, @milestone, *args)      
  end  

  def new_goal_path(*args)
    new_project_milestone_goal_path(Project.current, @milestone, *args)  
  end
  
  def edit_goal_path(*args)
    edit_project_milestone_goal_path(Project.current, @milestone, *args)  
  end
  
  def sprints_path(*args)
    project_milestone_sprints_path(Project.current, @milestone, *args)          
  end

  def sprint_path(*args)
    project_milestone_sprint_path(Project.current, @milestone, *args)          
  end
  
  def edit_sprint_path(*args)
    edit_project_milestone_sprint_path(Project.current, @milestone, *args)      
  end

  def story_path(*args)
    project_milestone_sprint_story_path(Project.current, @milestone, @sprint, *args)              
  end    

  def edit_story_path(*args)
    edit_project_milestone_sprint_story_path(Project.current, @milestone, @sprint, *args)              
  end    

  def backlog_stories_path(*args)
    backlog_project_milestone_sprint_stories_path(Project.current, @milestone, @sprint, *args)              
  end    

  [:new, :accept, :complete, :reopen, :comment, :update_progress, :revise_hours].each do |prefix|
    method_definition =<<-EOM
      def #{prefix}_story_path(*args)
        #{prefix}_project_milestone_sprint_story_path(Project.current, @milestone, @sprint, *args)              
      end    
    EOM
    module_eval method_definition, __FILE__, __LINE__
  end

  def milestone_runtime(milestone, separator = nil, &block)
    parts = []                      
    if milestone.started_on
      parts << [_('Started'), date_format(milestone.started_on)] 
    end
    if milestone.finished_on
      parts << [_('Completed'), date_format(milestone.finished_on)] 
    elsif milestone.due
      parts << [_('Due'), date_format(milestone.due)] 
    end
    
    parts.map do |tokens|
      yield(*tokens)
    end.join(separator.to_s)
  end

  def include_agile_pm_stylesheet
    content_for :header do
      x_stylesheet_link_tag('agile_pm')      
    end
  end

  def include_swf_object_js
    content_for :header do
      x_javascript_include_tag('swf_object')      
    end
  end
  
  def include_plus_chart_js
    content_for :header do
      x_javascript_include_tag('plus_chart')      
    end
  end
  
end
