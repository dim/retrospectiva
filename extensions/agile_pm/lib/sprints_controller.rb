#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class SprintsController < ProjectAreaController
  retrospectiva_extension('agile_pm')
  menu_item :use => 'GoalsController'

  require_permissions :goals,
    :view   => ['show']

  require_permissions :sprints,
    :create => ['new', 'create'],
    :update => ['edit', 'update'],
    :delete => ['destroy']

  before_filter :find_milestone
  before_filter :find_sprint, :only => [:show, :edit, :update, :destroy]
  helper_method :sprint_location

  def show    
    respond_to :json
  end

  def new
    @sprint = @milestone.sprints.new :title => 'Sprint '

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sprint }
    end
  end

  def create
    @sprint = @milestone.sprints.new(params[:sprint])
    
    respond_to do |format|
      if @sprint.save
        flash[:notice] = _('Sprint was successfully created.')
        format.html { redirect_to(sprint_location) }
        format.xml  { render :xml => @sprint, :status => :created, :location => sprint_location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sprint.errors, :status => :unprocessable_entity }
      end
    end    
  end

  def edit    
  end

  def update
    respond_to do |format|
      if @sprint.update_attributes(params[:sprint])
        flash[:notice] = _('Sprint was successfully updated.')
        format.html { redirect_to sprint_location }
        format.xml  { head :ok }        
      else        
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sprint.errors, :status => :unprocessable_entity }
      end
    end    
  end

  def destroy
    @sprint.destroy
    flash[:notice] = _('Sprint was successfully deleted.')

    respond_to do |format|
      format.html { redirect_to project_milestone_goals_path(Project.current, @milestone) }
      format.xml  { head :ok }
    end
  end

  private

    def sprint_location
      project_milestone_goals_path(Project.current, @milestone, :anchor => @sprint.title.parameterize )              
    end
  
    def find_milestone
      @milestone = Project.current.milestones.find params[:milestone_id]
    end
    
    def find_sprint
      @sprint = @milestone.sprints.find params[:id]          
    end
  
end
