#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::ProjectsController < AdminAreaController
  verify_restful_actions!  
  before_filter :paginate_projects, :only => [:index]
  before_filter :find_repositories, :only => [:new, :edit]
  before_filter :new, :only => [:create]
  before_filter :find_project, :only => [:edit, :update, :destroy]
  verify_action :repository_validation, :xhr => true

  def index
  end

  def new
    @project = Project.new(params[:project])
  end

  def create
    if @project.save
      flash[:notice] = _('Project was successfully created.')
      redirect_to admin_projects_path
    else
      find_repositories
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @project.update_attributes(params[:project])
      flash[:notice] = _('Project was successfully updated.')
      redirect_to admin_projects_path
    else
      find_repositories
      render :action => 'edit'
    end    
  end
  
  def destroy
    if @project.destroy
      flash[:notice] = _('Project was successfully deleted.')
    else
      flash[:error] = ([_('Project could not be deleted. Following error(s) occured') + ':'] + @project.errors.full_messages)
    end
    redirect_to admin_projects_path
  end

  def repository_validation
    @result = if params[:repository_id].blank?
      _('No repository selected.')
    else
      path = params[:root_path] || ''
      node = Repository.find(params[:repository_id]).node(path).dir? rescue nil
      if node
        _('Success! Path is a directory in this repository.')
      else
        _('Failure! Path is not a directory in this repository.')
      end
    end
    render :inline => '&rarr; <%=h @result %>'
  end

  protected
    
    def paginate_projects
      @projects = Project.paginate(
        :order => 'name',
        :per_page => params[:per_page],
        :page => params[:page])
    end

    def find_repositories
      @repositories = Repository.find(:all, :order => 'name')
    end

    def find_project
      @project = Project.find_by_short_name(params[:id])
      project_not_found(params[:id]) unless @project
    end

end
