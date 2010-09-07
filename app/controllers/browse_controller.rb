class BrowseController < ProjectAreaController
  menu_item :browse_code do |i|
    i.label = N_('Browse Code')
    i.requires = lambda do |project| 
      project.active_repository?
    end
    i.path = lambda do |project| 
      project_browse_path(project)
    end
    i.rank = 200
  end

  require_permissions :code, 
    :browse => ['index', 'download', 'revisions', 'diff']  

  verify :params => [:compare_with], :only => :diff

  before_filter :fetch_node
  before_filter :check_freshness_of_node, :only => ['index']
  before_filter :verify_file_node, :only => ['download', 'diff']

  def index
    if @node.dir?
      # Render 'index' action 
    else
      render_node
    end
  end

  def download
    send_node
  end

  def revisions
    path_pattern = @node.path
    path_pattern = path_pattern.chomp('/') + '/%' if @node.dir?

    @revisions = Project.current.changesets.paginate(
      :include => [:changes],
      :page => params[:page],
      :conditions => ['changes.path LIKE ? AND changes.name != ?', path_pattern, 'D'],
      :per_page => 25,
      :order => 'changesets.created_at DESC')
  end

  def diff
    @unified_diff = @repository.unified_diff @node.path, params[:compare_with], @node.selected_revision
    send_diff if params[:format] == 'plain'
  end

  protected
    
    def check_freshness_of_node
      fresh_when :etag => @node, :last_modified => @node.date
    end

    def render_node
      case @node.content_type
      when :image
        render_image_node        
      when :binary
        render_binary_node
      else
        render_textual_node
      end      
    end
    
    def render_image_node
      params[:format] == 'raw' ? send_node : render_node_template(:show_image)
    end

    def render_binary_node
      params[:format] == 'raw' ? send_node : render_node_template(:show_binary)
    end

    def render_textual_node
      if params[:format] == 'raw'
        send_node
      elsif params[:format] == 'text' || @node.size > 512.kilobyte          
        send_node('text/plain', 'inline')
      else        
        render_node_template :show_file
      end
    end    
    
    def render_node_template(template)
      request.format = :html
      render template
    end
    
    def send_node(mime_type = nil, disposition = nil)
      send_data @node.content, 
        :type => ( mime_type || @node.mime_type.simplified ), 
        :disposition => ( disposition || @node.disposition )
    end
    
    def send_diff
      filename = "#{@node.name}-[#{params[:compare_with]}][#{@node.selected_revision}].diff"
      send_data @unified_diff,
        :type => 'text/plain', 
        :disposition => 'inline',
        :filename => filename
    end
    
  private

    def fetch_node
      params[:path] = [params[:path]].flatten.compact
      full_path = Project.current.absolutize_path params[:path].join('/')
      
      @repository = Project.current.repository
      revision = params[:rev].blank? ? @repository.latest_revision : params[:rev] 
      relative_path = '/' + Project.current.relativize_path(full_path)

      begin
        @node = @repository.node(full_path, revision)
        @changeset = Project.current.changesets.find_by_revision @node.selected_revision, :include => [:user]
      rescue Repository::RevisionNotFound
        message = _('Unable to find revision %{revision} for \'%{path}\', showing revision %{latest}.', :revision => revision, :path => relative_path, :latest => @repository.latest_revision)
        fail_with message, params[:path]
      rescue Repository::InvalidRevision
        message = _('Revision %{revision} seems not to be valid, showing revision %{latest}.', :revision => revision, :latest => @repository.latest_revision)
        fail_with message, params[:path]
      rescue Repository::Abstract::Node::InvalidPathForRevision
        message = _('Path \'%{path}\' does not exist in revision %{revision}, showing revision %{latest}.', :path => relative_path, :revision => revision, :latest => @repository.latest_revision)
        fail_with message, params[:path]
      rescue Repository::Abstract::Node::InvalidPath
        if relative_path.split('/').blank?
          render :action => 'repository_unavailable'
        else
          message = _('Path \'%{path}\' does not exist in revision %{revision}, showing root path.', :path => relative_path, :revision => revision)
          fail_with message, nil          
        end
      end
    end

    def fail_with(message, path = [], options = {})
      redirect_to project_browse_path(Project.current, path, options)    
    end

    def verify_file_node      
      redirect_to project_browse_path(Project.current, params[:path], params[:rev] ? { :rev => params[:rev] } : {}) if @node.dir?
    end
        
end
