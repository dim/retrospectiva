class ProjectAreaController < ApplicationController
  before_filter :find_project
  before_filter :authorize  

  class << self
    
    def menu_item(name, options = {}, &block)
      RetroAM.menu_map.push(self, name, options, &block)
    end
    
    def use_menu_item_from(controller_name)
      RetroAM.menu_links[name] = controller_name      
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
    ensure
      retain_back_to
    end
    
    def project_not_found!
      raise ActiveRecord::RecordNotFound, "Unable to find project '#{params[:project_id]}'"
    end

    def respond_with_defaults(klass = nil)
      respond_to do |format|
        format.html
        format.rss  { render_rss(klass) }
      end
    end

    def load_rss(klass = nil)
      klass ||= self.class.name.gsub(/Controller$/, '').singularize.constantize
      @rss_channel = klass.previewable.channel      
    end

    def render_rss(klass = nil)
      klass ||= self.class.name.demodulize.gsub(/Controller$/, '').singularize.constantize
      records = instance_variable_get("@#{klass.name.tableize}".to_sym)
      render :xml => klass.to_rss(records).to_s, :content_type => 'application/rss+xml'
    end

  private
  
    def retain_back_to
      session[:back_to] = request.path if request.get? and request.format.html?
    end
  
end
