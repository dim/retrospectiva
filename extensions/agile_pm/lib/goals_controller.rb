#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class GoalsController < ProjectAreaController
  retrospectiva_extension('agile_pm')

  menu_item :goals do |i|
    i.label = N_('Goals')
    i.rank = 300
    i.path = lambda do |project|
      project_goals_path(project)
    end
  end

  require_permissions :goals,
    :view   => ['home', 'index', 'show'],
    :create => ['new', 'create'],
    :update => ['edit', 'update'],
    :delete => ['destroy']

  before_filter :find_milestone, :except => [:home]
  before_filter :find_goal_associations, :only => [:new, :edit]
  before_filter :find_goal, :only => [:show, :edit, :update, :destroy]

  helper_method :sprint_location

  def home
    @milestone = Project.current.milestones.in_order_of_relevance.first
    if @milestone.present?
      redirect_to project_milestone_goals_path(Project.current, @milestone)      
    else
      render :action => 'no_milestones'
    end
  end

  def index
    @milestones     = Project.current.milestones.in_default_order.all
    @current_sprint = @milestone.sprints.in_order_of_relevance.first
    @goals = @milestone.goals.group_by(&:sprint)
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @goals.values.flatten }
    end
  end

  def show    
    respond_to do |format|
      format.html # show.html.erb
      format.js   # show.js.rjs
      format.xml  { render :xml => @goal }
    end    
  end

  def new
    @goal = @milestone.goals.new(:sprint_id => params[:sprint_id], :requester_id => User.current.id)     

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @goal }
    end
  end

  def create
    @goal = @milestone.goals.new(params[:goal])

    respond_to do |format|
      if @goal.save
        flash[:notice] = _('Goal was successfully created.')
        format.html { redirect_to sprint_location }
        format.xml  { render :xml => @goal, :status => :created, :location => sprint_location }        
      else        
        format.html { find_goal_associations; render :action => "new" }
        format.xml  { render :xml => @goal.errors, :status => :unprocessable_entity }
      end
    end    
  end

  def edit
  end

  def update
    respond_to do |format|
      if @goal.update_attributes(params[:goal])
        flash[:notice] = _('Goal was successfully updated.')
        format.html { redirect_to sprint_location }
        format.xml  { head :ok }        
      else        
        format.html { find_goal_associations; render :action => "edit" }
        format.xml  { render :xml => @goal.errors, :status => :unprocessable_entity }
      end
    end    
  end

  def destroy
    @goal.destroy
    flash[:notice] = _('Goal was successfully deleted.')

    respond_to do |format|
      format.html { redirect_to project_milestone_goals_path(Project.current, @milestone) }
      format.xml  { head :ok }
    end
  end


  private

    def sprint_location
      hash = @goal.sprint ? @goal.sprint.title.parameterize : 'unassigned'
      project_milestone_goals_path(Project.current, @milestone, :anchor => hash )              
    end

    def find_milestone
      @milestone = Project.current.milestones.find params[:milestone_id],
        :include => [:sprints, :goals], 
        :order => 'goals.priority_id DESC, goals.title'
    end
  
    def find_goal_associations
      @sprints = @milestone.sprints.all(:order => 'starts_on, finishes_on')
      @users = Project.current.users.with_permission(:goals, :view)
    end
  
    def find_goal
      @goal = @milestone.goals.find params[:id], 
        :include => [:sprint, :stories], 
        :order => 'stories.title'     
    end
  
  
end
