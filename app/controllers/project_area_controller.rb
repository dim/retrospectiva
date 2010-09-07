class ProjectAreaController < ApplicationController
  before_filter :find_project
  before_filter :authorize  

  class << self
    
    def menu_item(*args, &block)
      options = args.extract_options!
      
      if args.first      
        RetroAM.menu_map.push(self, args.first, options, &block)
      elsif options[:use]
        RetroAM.menu_links[name] = options[:use]        
      elsif options[:none]
        RetroAM.menu_links[name] = options[:use]        
      end      
    end
    
    def authorize?(action_name, request_params = {}, user = User.current, project = Project.current)
      name = RetroAM.menu_links[self.name] || self.name
      item = RetroAM.menu_items.find {|i| i.active?(name, action_name) }
      module_enabled?(project, item) && module_accessible?(project, item) ? super : false
    end       
    
    def module_enabled?(project, item)
      project.present? and item.present? and project.enabled_modules.include?(item.name)
    end    
    protected :module_enabled?
    
    def module_accessible?(project, item)
      project.present? and item.present? and item.accessible?(project)
    end    
    protected :module_accessible?
  
  end
  
  protected
    
    def fresh_when(options = {})
      options[:etag] = [User.current, Project.current, flash] + Array.wrap(options[:etag])
      options[:last_modified] = ([User.current, Project.current].map(&:updated_at) + Array.wrap(options[:last_modified])).compact.max
      super      
    end    
  
    def find_project
      project = Project.find_by_short_name! params[:project_id]      
      Project.current = User.current.projects.active.find(project.short_name)
      I18n.locale = Project.current.locale if Project.current && Project.current.locale    
    end
    
    def render_rss(klass, records = nil, options = {})
      records ||= instance_variable_get("@#{klass.name.tableize}".to_sym)
      render :xml => klass.to_rss(records, options).to_s, :content_type => 'application/rss+xml'
    end

end
