#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class WikiFilesController < ProjectAreaController
  retrospectiva_extension('retro_wiki')
  
  menu_item :use => 'WikiController'
  
  require_permissions :wiki_pages,
    :view   => ['index', 'show']
    
  require_permissions :wiki_files,
    :create => ['new', 'create'],
    :delete => ['destroy']

  before_filter :check_freshness_of_index, :only => [:index]
  before_filter :find_file, :only => [:show, :destroy]
  before_filter :verify_readablity, :only => [:show]
  before_filter :check_freshness_of_file, :only => [:show]
  before_filter :assert_file_params, :only => [:new, :create]
  before_filter :new, :only => [:create]

  def index
    @files = Project.current.wiki_files.paginate :page => params[:page], :order => 'wiki_title'    
  end
  
  def show
    @wiki_file.redirect? ? redirect_to(@wiki_file.redirect) : send_file(*@wiki_file.send_arguments)
  end
  
  def new
    @wiki_file = Project.current.wiki_files.new(params[:wiki_file][:file])
  end
  
  def create
    @wiki_file.wiki_title = params[:wiki_file][:wiki_title]
    if @wiki_file.save
      flash[:notice] = _('File was successfully added.')
      redirect_to project_wiki_files_path(Project.current)
    else
      render :action => 'new'
    end    
  end

  def destroy
    if @wiki_file.destroy
      flash[:notice] = _('File was successfully deleted.')
    else
      flash[:error] = _('File cannot be deleted.')      
    end
    redirect_to project_wiki_files_path(Project.current)
  end

  protected
  
    def check_freshness_of_index
      fresh_when :etag => Project.current.wiki_files.count, :last_modified => Project.current.wiki_files.maximum(:created_at)      
    end

    def check_freshness_of_file
      fresh_when :etag => @wiki_file, :last_modified => @wiki_file.created_at      
    end
  
    def find_file
      @wiki_file = Project.current.wiki_files.find_by_wiki_title! params[:id]
    end    

    def verify_readablity      
      render :text => _('Unable to download file') unless @wiki_file.readable?
    end

    def assert_file_params
      params[:wiki_file] = {} unless params[:wiki_file].is_a?(Hash)
    end

end
