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

  before_filter :edit, :only => :update
  
  def index
    @milestones = if params[:completed] == '1'
      Project.current.milestones.paginate options_for_pagination
    else
      Project.current.milestones.active_on(Date.today).paginate options_for_pagination
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

  def edit
    @milestone = Project.current.milestones.find(params[:id])
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
    @milestone = Project.current.milestones.find(params[:id])
    @milestone.destroy
    flash[:notice] = _('Milestone was successfully deleted.')

    respond_to do |format|
      format.html { redirect_to(project_milestones_path(Project.current)) }
      format.xml  { head :ok }
    end
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
