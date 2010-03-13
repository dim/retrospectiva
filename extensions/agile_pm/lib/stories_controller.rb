#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class StoriesController < ProjectAreaController
  retrospectiva_extension('agile_pm')
  keep_params! :only => [:index], :include => [:show]

  menu_item :stories do |i|
    i.label = N_('Stories')
    i.rank = 400
    i.path = lambda do |project|
      project_stories_path(project)
    end
  end

  require_permissions :stories,
    :view   => ['home', 'index', 'show', 'chart', 'backlog'],
    :create => ['new', 'create'],
    :modify => ['edit', 'update'],
    :update => ['accept', 'complete', 'reopen', 'comment', 'update_progress', 'revise_hours'],
    :delete => ['destroy']

  before_filter :find_sprint, :except => [:home]  
  before_filter :guess_sprint, :only => [:home]  
  before_filter :find_milestones, :only => [:index]  
  before_filter :find_story, 
    :only => [:show, :edit, :update, :accept, :complete, :reopen, :comment, :update_progress, :revise_hours]  
  helper_method :stories_path, :story_path
  
  def home
    if @sprint.present?
      redirect_to project_milestone_sprint_stories_path(Project.current, @milestone, @sprint)       
    else
      render :action => 'no_sprints'
    end        
  end
  
  def index
    @stories = find_stories.in_default_order.
      all(:include => [:progress_updates, :creator, :assigned]).
      group_by(&:assigned)

    respond_to do |format|
      format.html
      format.xml { render :xml => @stories }
    end
  end
  
  def backlog
    respond_to do |format|
      format.html
    end    
  end
  
  def show
    @story_comment = @story.comments.new
    respond_to do |format|
      format.html
      format.js
      format.xml  { render :xml => @story }
    end    
  end
  
  def new
    @story = @sprint.stories.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @story }
    end    
  end

  def create
    @story = @sprint.stories.new(params[:story])
    
    respond_to do |format|
      if @story.save
        flash[:notice] = _('Story was successfully created.')
        format.html { redirect_to stories_path }
        format.xml  { render :xml => @story, :status => :created, :location => story_path(@story) }        
      else        
        format.html { render :action => "new" }
        format.xml  { render :xml => @story.errors, :status => :unprocessable_entity }
      end
    end    
  end

  def edit
    respond_to :html
  end

  def update
    respond_to do |format|
      if @story.update_attributes(params[:story])
        flash[:notice] = _('Story was successfully updated.')
        format.html { redirect_to stories_path }
        format.xml  { render :xml => @story, :status => :updated, :location => story_path(@story) }        
      else        
        format.html { render :action => "edit" }
        format.xml  { render :xml => @story.errors, :status => :unprocessable_entity }
      end
    end    
  end

  def accept
    @story.accept!
    respond_to_update _('Story was accepted.')
  end

  def complete
    @story.complete!
    respond_to_update _('Story was completed.')
  end

  def reopen
    @story.reopen!
    respond_to_update _('Story was re-opened.')
  end
  
  def comment
    @story_comment = @story.comments.new(params[:story_comment])

    respond_to do |format|
      if @story_comment.save
        @story_comment = @story.comments.new
        format.js
        format.xml { head :ok }
      else
        format.js
        format.xml { render :xml => @story_comment.errors, :status => :unprocessable_entity }      
      end
    end   
  end

  def update_progress
    @progress_update = @story.progress_updates.find_or_initialize(Time.zone.today, params[:value]) 

    respond_to do |format|
      if @progress_update.save
        find_sprint
        format.js
        format.xml { head :ok }
      else
        format.js  { head :unprocessable_entity }
        format.xml { render :xml => @progress_update.errors, :status => :unprocessable_entity }      
      end
    end
  end

  def revise_hours
    @story.revised_hours = params[:value].to_i
    
    respond_to do |format|
      if @story.save
        find_sprint
        format.js
        format.xml { head :ok }
      else
        format.js  { head :unprocessable_entity }
        format.xml { render :xml => @story.errors, :status => :unprocessable_entity }
      end
    end
  end

  protected

    def respond_to_update(message = nil)
      respond_to do |format|
        if @story.save
          flash[:notice] = message if message          
          format.html { redirect_to(stories_path) }
          format.xml  { head :ok }        
        else        
          format.html { redirect_to(stories_path) }
          format.xml  { render :xml => @story.errors, :status => :unprocessable_entity }
        end
      end    
    end    
    
    def stories_path(*args)
      project_milestone_sprint_stories_path(Project.current, @milestone, @sprint, *args)
    end

    def story_path(*args)
      project_milestone_sprint_story_path(Project.current, @milestone, @sprint, *args)
    end

  private
  
    def find_sprint
      @milestone = Project.current.milestones.find params[:milestone_id]
      @sprint    = @milestone.sprints.find params[:sprint_id],
        :include => [{:stories => [:assigned, :progress_updates]}, :goals] 
    end

    def guess_sprint
      @milestone = if params[:milestone_id] 
        Project.current.milestones.find(params[:milestone_id])
      else
        Project.current.milestones.in_order_of_relevance.find :first, :joins => :sprints
      end      
      @sprint = @milestone.sprints.in_order_of_relevance.first if @milestone
    end

    def find_milestones
      @milestones = Project.current.milestones.in_default_order.find :all,
        :include => [{ :sprints => :stories }],
        :order => 'sprints.starts_on, sprints.finishes_on'
    end
    
    def find_story
      @story = @sprint.stories.find(params[:id], :include => :goal)     
    end
    
    def find_stories
      case params[:show]
      when 'pending'
        @sprint.stories.pending
      when 'completed'
        @sprint.stories.completed
      else
        @sprint.stories.active
      end
    end
         
end
