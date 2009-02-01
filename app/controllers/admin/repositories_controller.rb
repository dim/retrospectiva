#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::RepositoriesController < AdminAreaController
  verify :xhr => true, :only => :validate

  before_filter :paginate_repositories, :only => [:index]
  before_filter :new, :only => [:create]
  before_filter :find_repository, :only => [:edit, :update]

  def index
  end

  def new
    kind = params[:repository] ? params[:repository][:kind] : nil
    klass = (Repository[kind] || Repository::Subversion)
    @repository = klass.new(params[:repository])        
  end
  
  def create    
    if @repository.save
      flash[:notice] = _('Repository was successfully created.')
      redirect_to admin_repositories_path
    else
      render :action => 'new'
    end
  end
  
  def edit
  end

  def update
    if @repository.update_attributes(params[:repository])
      flash[:notice] = _('Repository was successfully updated.')
      redirect_to admin_repositories_path
    else
      render :action => 'edit'
    end  
  end
  
  def destroy
    if Repository.destroy(params[:id])
      flash[:notice] = _('Repository was successfully deleted.')
    end
    redirect_to admin_repositories_path
  end
  
  def validate
    path = params[:path].blank? ? '' : params[:path]
    @result = if !File.exists?(path)
      _('Failure! Path does not exist.')
    elsif !File.readable?(path) || !File.executable?(path)
      _('Failure! You are not permitted to browse this path.')
    else
      begin        
        repos = Repository[params[:kind]].new(:path => params[:path])
        _('Success! Path contains a valid repository (latest revision: {{latest}}).', :latest => repos.latest_revision)
      rescue 
        _('Failure! Path does not contain a valid repository.')
      end
    end
    render :inline => '&rarr; <%=h @result %>'
  end
  
  protected

    def paginate_repositories
      @repositories = Repository.paginate(
        :order => 'name',
        :per_page => params[:per_page],
        :page => params[:page])
    end

    def find_repository
      @repository = Repository.find(params[:id])
    end
    
  
  
end
