ActionController::Routing::Routes.draw do |map|

  map.root :controller => 'projects'
  map.login   'login',  :controller => 'sessions', :action => 'new'
  map.logout  'logout', :controller => 'sessions', :action => 'destroy'

  map.resource :session, :new => {:secure => :post}
  map.resource :account do |account|
    account.activate 'activate/:username/:code', :controller => 'accounts', :action => 'activate', :username => nil, :code => nil
    account.forgot_password 'forgot_password', :controller => 'accounts', :action => 'forgot_password'
  end
  
  
  pt_collection_methods = { :search => :any, :users => :post }
  pt_member_methods     = { :modify_summary => :put, :modify_content => :put, :modify_change_content => :put, :toggle_subscription => :post }
  
  map.resources :projects do |project|

    project.filter 'central_project'

    project.resources :changesets, :member => { :diff => :get }    
    project.resources :tickets, :collection => pt_collection_methods, :member => pt_member_methods do |ticket|
      ticket.download 'download/:id/:file_name', :controller => 'tickets', :action => 'download', :file_name => /.+/
      ticket.destroy_change ':id', :controller => 'tickets', :action => 'destroy_change', :conditions => { :method => :delete }, :requirements => { :id => /\d+/ }
    end
    project.resources :ticket_reports, :collection => { :sort => :put }    
    project.resources :milestones    
    project.with_options :controller => 'browse' do |browse|
      browse.browse    'browse/*path'
      browse.revisions 'revisions/*path', :action => 'revisions'
      browse.download  'download/*path', :action => 'download'
      browse.diff      'diff/*path', :action => 'diff'
    end
    project.with_options :controller => 'search' do |search|
      search.search    'search'
    end

  end


  map.with_options :controller => 'rss' do |rss|
    rss.rss 'rss'
  end

  map.with_options :controller => 'markup' do |markup|
    markup.markup_preview 'markup/preview.js', :action => 'preview', :format => 'js'
    markup.markup_reference 'markup/reference', :action => 'reference'
  end

  map.admin 'admin', :controller => 'admin/dashboard'
  map.namespace :admin do |admin|
    admin.resources :projects, :collection => { :repository_validation => :any } do |projects|
      projects.resources :ticket_properties, :collection => { :sort => :put } do |properties|
        properties.resources :values, :controller => 'ticket_property_values', :collection => { :sort => :put }
      end
    end
    admin.resources :repositories, :collection => { :validate => :any }
    admin.resources :users, :collection => { :search => :any }
    admin.resources :groups
    admin.resources :tasks, :collection => { :save => :put }
    admin.setup 'setup.:format', :controller => 'setup', :conditions => { :method => :get }    
    admin.setup 'setup.:format', :controller => 'setup', :action => 'save', :conditions => { :method => :put }    
    admin.extensions 'extensions', :controller => 'extensions'
  end

  Retrospectiva::ExtensionManager::Routes.apply(map)
end
