class ProjectsController < ApplicationController  
  before_filter :find_projects
 
  def index
    if User.current.public? && @projects.empty?
      flash.keep
      redirect_to login_path
    elsif @projects.size == 1
      flash.keep
      redirect_to @projects.first.path_to_first_menu_item      
    end    
  end
  
  def show
    @project = @projects.find(params[:id])
    if @project
      redirect_to @project.path_to_first_menu_item
    else
      redirect_to projects_path
    end
  end  

  protected

    def find_projects
      @projects = User.current.active_projects
      @projects.reject! do |project|
        project_has_no_accessible_menu_items?(project)
      end
    end

    def project_has_no_accessible_menu_items?(project)
      project.enabled_menu_items.find do |item|
        path = item.path(self, project)

        if User.current.has_access?(path)
          project.path_to_first_menu_item = path
          true
        else 
          nil
        end
      end.nil?
    end
        
end
