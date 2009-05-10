#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::ProjectsController < AdminAreaController
  before_filter :paginate_projects, :only => [:index]
  before_filter :find_repositories, :only => [:new, :edit]
  before_filter :find_project, :only => [:edit, :update, :destroy]
  verify :xhr => true, :only => :repository_validation

  def index
    respond_to do |format|
      format.html
      format.xml  { render :xml => @projects.to_xml }
    end
  end

  def new
    @project = Project.new(params[:project])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        flash[:notice] = _('Project was successfully created.')
        format.html { redirect_to admin_projects_path }
        format.xml  { render :xml => @project, :status => :created, :location => admin_projects_path }
      else
        find_repositories
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = _('Project was successfully updated.')
        format.html { redirect_to admin_projects_path }
        format.xml  { head :ok }        
      else
        find_repositories
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end    
    end    
  end
  
  def destroy
    respond_to do |format|
      if @project.destroy
        flash[:notice] = _('Project was successfully deleted.')
        format.html { redirect_to(admin_projects_path) }
        format.xml  { head :ok }
      else
        flash[:error] = ([_('Project could not be deleted. Following error(s) occured') + ':'] + @project.errors.full_messages)
        format.html { redirect_to(admin_projects_path) }
        format.xml  { render :xml => @project.errors, :status => :unprocessable_entity }
      end
    end
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
    
    respond_to do |format|
      format.html { render :inline => '&rarr; <%=h @result %>' }
    end
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
      @project = Project.find_by_short_name! params[:id]
    end

end
