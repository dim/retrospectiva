#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
RetroEM::Routes.draw do |map|

  map.resources :projects do |project|
    project.resources :wiki_pages, :as => 'wiki', :controller => 'wiki', :member => { :update_title => :put, :rename => :any }      
    project.resources :wiki_files
  end
  
end
