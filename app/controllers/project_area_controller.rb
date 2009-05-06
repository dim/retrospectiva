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
  
    def find_project
      Project.current = User.current.active_projects.find(params[:project_id])
      Project.current || project_not_found!
    end
    
    def project_not_found!
      raise ActiveRecord::RecordNotFound, "Unable to find project '#{params[:project_id]}'"
    end

    def render_rss(klass, records = nil)
      records ||= instance_variable_get("@#{klass.name.tableize}".to_sym)
      render :xml => klass.to_rss(records).to_s, :content_type => 'application/rss+xml'
    end

    def failed_authorization!
      if User.current.public? and request.get? and ( request.format.nil? or request.format.html? )
        session[:back_to] = "#{ActionController::Base.relative_url_root}#{request.path}"
        redirect_to login_path
      else
        super
      end
    end

end
