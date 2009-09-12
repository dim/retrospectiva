#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
RetroEM::Routes.draw do |map|

  map.goals 'goals.:format', 
    :controller => 'goals', 
    :action => 'home',
    :path_prefix => '/projects/:project_id',
    :name_prefix => 'project_'
    
  map.resources :goals, 
    :path_prefix => '/projects/:project_id/milestones/:milestone_id',
    :name_prefix => 'project_milestone_'

  map.resources :sprints,
    :path_prefix => '/projects/:project_id/milestones/:milestone_id',
    :name_prefix => 'project_milestone_'

  map.stories 'stories.:format', 
    :controller => 'stories', 
    :action => 'home',
    :path_prefix => '/projects/:project_id',
    :name_prefix => 'project_'
    
  map.stories 'stories.:format', 
    :controller => 'stories', 
    :action => 'home',
    :path_prefix => '/projects/:project_id/milestones/:milestone_id',
    :name_prefix => 'project_milestone_'

  map.resources :stories, 
    :path_prefix => '/projects/:project_id/milestones/:milestone_id/sprints/:sprint_id',
    :name_prefix => 'project_milestone_sprint_',
    :collection => { :backlog => :get },
    :member => { :accept => :put, :complete => :put, :reopen => :put, :update_progress => :put, :revise_hours => :put, :comment => :post }

end
