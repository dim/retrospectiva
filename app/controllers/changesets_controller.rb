class ChangesetsController < ProjectAreaController
  menu_item :changesets do |i|
    i.label = N_('Changesets')
    i.requires = lambda do |project| 
      project.active_repository?
    end
    i.rank = 100
  end
  require_permissions :changesets, 
    :view => ['index', 'show']  
  keep_params! :only => [:index], :exclude => [:project_id]

  before_filter :load_rss, :only => :index

  def index
    @changesets = Project.current.changesets.paginate(
      :include => [:user],
      :page => ( request.format.rss? ? 1 : params[:page] ),
      :per_page => ( request.format.rss? ? 10 : nil ),
      :order => 'changesets.revised_at DESC')
    respond_with_defaults
  end
  
  def show
    @changeset = Project.current.changesets.find_by_revision! params[:id],
      :include => [:changes, :user]

    @next_changeset = @changeset.next_by_project(Project.current)
    @previous_changeset = @changeset.previous_by_project(Project.current)
  end

end
