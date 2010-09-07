#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::RepositoriesController < AdminAreaController
  verify :xhr => true, :only => :validate

  before_filter :paginate_repositories, :only => [:index]
  before_filter :new_repository, :only => [:new, :create]
  before_filter :find_repository, :only => [:edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html
      format.xml  { render :xml => @repositories.to_xml }
    end
  end

  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @repository }
    end
  end
  
  def create
    respond_to do |format|
      if @repository.save
        flash[:notice] = _('Repository was successfully created.')
        format.html { redirect_to admin_repositories_path }
        format.xml  { render :xml => @repository, :status => :created, :location => admin_repositories_path }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @repository.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
  end

  def update
    respond_to do |format|
      if @repository.update_attributes(params[:repository])
        flash[:notice] = _('Repository was successfully updated.')
        format.html { redirect_to admin_repositories_path }
        format.xml  { head :ok }        
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @repository.errors, :status => :unprocessable_entity }
      end  
    end  
  end
  
  def destroy    
    @repository.destroy
    flash[:notice] = _('Repository was successfully deleted.')
    
    respond_to do |format|
      format.html { redirect_to admin_repositories_path }
      format.xml  { head :ok }
    end    
  end
  
  def validate
    path  = params[:path].blank? ? '' : params[:path]
    klass = Repository[params[:kind]]

    @result = if klass.nil? or !klass.enabled? 
      _('Support for %{system} is not enabled.', :system => params[:kind].to_s.classify)
    elsif !File.exists?(path)
      _('Failure! Path does not exist.')
    elsif !File.readable?(path) || !File.executable?(path)
      _('Failure! You are not permitted to browse this path.')
    else
      repos = klass.new(:path => params[:path])
      if repos.active?
        _('Success! Path contains a valid repository (latest revision: %{latest}).', :latest => repos.latest_revision)
      else
        _('Failure! Path does not contain a valid repository.')
      end
    end

    respond_to do |format|
      format.html { render :inline => '&rarr; <%=h @result %>' }
    end
  end
  
  protected

    def paginate_repositories
      @repositories = Repository.paginate :page => params[:page],
        :order => 'name',
        :per_page => params[:per_page]
    end

    def find_repository
      @repository = Repository.find(params[:id])
    end
    
    def new_repository
      kind = params[:repository] ? params[:repository][:kind] : nil
      klass = (Repository[kind] || Repository::Git)
      @repository = klass.new(params[:repository])
    end
  
end
