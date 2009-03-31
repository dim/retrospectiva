class MilestonesController < ProjectAreaController
  menu_item :milestones do |i|
    i.label = N_('Milestones')
    i.rank = 300
  end
  require_permissions :milestones, 
    :view   => ['index', 'show'],
    :create => ['new', 'create'], 
    :update => ['edit', 'update'], 
    :delete => ['destroy']

  enable_private_rss! :only => :index
  before_filter :new, :only => :create
  before_filter :edit, :only => :update
  
  def index
    @milestones = if params[:completed] == '1'
      Project.current.milestones.paginate options_for_pagination
    else
      Project.current.milestones.active_on(Date.today).paginate options_for_pagination
    end
    respond_with_defaults
  end

  def new
    @milestone = Project.current.milestones.new(params[:milestone])
  end

  def edit
    @milestone = Project.current.milestones.find(params[:id])
  end

  def create
    if @milestone.save
      flash[:notice] = _('Milestone was successfully created.')
      redirect_to project_milestones_path(Project.current)
    else
      render :action => 'new'
    end
  end

  def update
    if @milestone.update_attributes(params[:milestone])
      flash[:notice] = _('Milestone was successfully updated.')
      redirect_to project_milestones_path(Project.current)
    else
      render :action => 'edit'
    end
  end

  def destroy
    Project.current.milestones.destroy(params[:id])
    flash[:notice] = _('Milestone was successfully deleted.')
    redirect_to project_milestones_path(Project.current)
  end

  private
  
    def options_for_pagination
      {
        :page => ( request.format.rss? ? 1 : params[:page] ), 
        :per_page => ( request.format.rss? ? 10 : nil ),
        :include => {:tickets => :status},
        :order => Milestone.default_order
      }
    end    

end
