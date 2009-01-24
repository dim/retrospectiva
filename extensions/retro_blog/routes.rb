#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
RetroEM::Routes.draw do |map|

  map.resources :projects do |project|
    project.resources :blog_posts, :as => 'blog', :controller => 'blog' do |posts|
      posts.resources :comments, :controller => 'blog_comments'
    end
  end
  
end
