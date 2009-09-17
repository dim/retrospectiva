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

  before_filter :check_freshness_of_index, :only => [:index]
  before_filter :find_milestone, :only => [:edit, :update, :destroy]
  
  def index
    @milestones = if params[:completed] == '1'
      Project.current.milestones.in_default_order.paginate options_for_pagination
    else
      Project.current.milestones.in_default_order.active_on(Date.today).paginate options_for_pagination
    end

    respond_to do |format|
      format.html
      format.rss  { render_rss(Milestone) }
      format.xml  { render :xml => @milestones }
    end
  end

  def new
    @milestone = Project.current.milestones.new(params[:milestone])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @milestone }
    end
  end

  def create
    @milestone = Project.current.milestones.new(params[:milestone])

    respond_to do |format|
      if @milestone.save
        flash[:notice] = _('Milestone was successfully created.')
        format.html { redirect_to project_milestones_path(Project.current) }
        format.xml  { render :xml => @milestone, :status => :created, :location => project_milestones_path(Project.current) }        
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @milestone.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @milestone.update_attributes(params[:milestone])
        flash[:notice] = _('Milestone was successfully updated.')
        format.html { redirect_to(project_milestones_path(Project.current)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @milestone.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @milestone.destroy
    flash[:notice] = _('Milestone was successfully deleted.')

    respond_to do |format|
      format.html { redirect_to(project_milestones_path(Project.current)) }
      format.xml  { head :ok }
    end
  end

  private
    
    def check_freshness_of_index
      fresh_when :etag => Project.current.milestones.count, :last_modified => Project.current.milestones.maximum(:updated_at)
    end
  
    def find_milestone
      @milestone = Project.current.milestones.find(params[:id])      
    end
  
    def options_for_pagination
      {
        :page => ( request.format.rss? ? 1 : params[:page] ), 
        :per_page => ( request.format.rss? ? 10 : nil ),
        :include => {:tickets => :status},
        :total_entries => ( request.format.rss? ? 10 : nil ),       
      }
    end    

end
