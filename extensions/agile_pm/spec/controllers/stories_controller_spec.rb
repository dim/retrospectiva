require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoriesController do
  it_should_behave_like EveryProjectAreaController

  class << self
    
    def it_assigns_the_milestone(method = :do_get)
      it "assigns milestone as @milestone" do
        @milestones.should_receive(:find).with('1').and_return(@milestone)
        send(method)
        assigns[:milestone].should == @milestone
      end
    end

    def it_assigns_the_sprint(method = :do_get)
      it "assigns sprint as @sprint" do
        @sprints.should_receive(:find).
          with('37', :include => [{:stories => [:assigned, :progress_updates]}, :goals]).
          and_return(@sprint)
        send(method)
        assigns[:sprint].should == @sprint
      end
    end

    def it_assigns_the_story(method = :do_get)
      it "assigns sprint as @sprint" do
        @stories.should_receive(:find).with('73', :include => :goal).and_return(@story)
        send(method)
        assigns[:story].should == @story
      end
    end
    
  end    


  before do   
    @user = mock_model(User)

    @comment = mock_model(StoryComment)
    @comments = [@comment]
    @comments.stub!(:new).and_return(@comment)

    @progress_update = mock_model(StoryProgressUpdate)
    @progress_updates = [@progress_update]
    @progress_updates.stub!(:new).and_return(@progress_update)

    @story = mock_model(Story, :assigned => @user)
    @story.stub!(:comments).and_return(@comments)    
    @story.stub!(:progress_updates).and_return(@progress_updates)    
    @stories = [@story]
    @stories.stub!(:in_default_order).and_return(@stories)
    @stories.stub!(:pending).and_return(@stories)
    @stories.stub!(:completed).and_return(@stories)
    @stories.stub!(:active).and_return(@stories)
    @stories.stub!(:all).and_return(@stories)
    @stories.stub!(:find).with('73', :include => :goal).and_return(@story)
    @stories.stub!(:new).and_return(@story)
    
    @sprint = mock_model(Sprint, :title => 'Sprint 1')
    @sprint.stub!(:stories).and_return(@stories)
    @sprints = [@sprint]
    @sprints.stub!(:find).
      with('37', :include => [{:stories => [:assigned, :progress_updates]}, :goals]).
      and_return(@sprint)

    @milestone = mock_model(Milestone)
    @milestone.stub!(:sprints).and_return(@sprints)    
    @milestones = [@milestone]
    @milestones.stub!(:in_default_order).and_return(@milestones)
    @milestones.stub!(:find).
      with(:all, :include => [{ :sprints => :stories }], :order => 'sprints.starts_on, sprints.finishes_on').
      and_return(@milestones)
    @milestones.stub!(:find).with('1').and_return(@milestone)
    
    @project = permit_access_with_current_project! :milestones => @milestones, :name => 'Retrospectiva'    
  end


  describe "GET index" do
    
    def do_get(options = {})
      get :index, options.merge(:project_id => 'retro', :milestone_id => '1', :sprint_id => '37')
    end
    
    it_assigns_the_milestone
    it_assigns_the_sprint

    it "assigns all milestones as @milestones" do
      @milestones.should_receive(:in_default_order).and_return(@milestones)
      do_get
      assigns[:milestones].should == @milestones
    end

    it "assigns all active stories indexed as @stories" do
      @stories.should_receive(:active).and_return(@stories)
      do_get
      assigns[:stories].should == { @user => @stories }
    end

    it "assigns all pending/completed stories as @stories of requested" do
      @stories.should_receive(:pending).and_return(@stories)
      do_get(:show => 'pending')
      assigns[:stories].should == { @user => @stories }
    end

  end


  describe "GET backlog" do
    
    def do_get(options = {})
      get :backlog, :project_id => 'retro', :milestone_id => '1', :sprint_id => '37'
    end
    
    it_assigns_the_milestone
    it_assigns_the_sprint
  end


  describe "GET show" do
    
    def do_get(options = {})
      get :show, :project_id => 'retro', :milestone_id => '1', :sprint_id => '37', :id => '73'
    end
    
    it_assigns_the_milestone
    it_assigns_the_sprint
    it_assigns_the_story
    
    it "assigns a new comment as @story_comment" do
      @comments.should_receive(:new).with().and_return(@comment)
      do_get
      assigns[:story_comment].should equal(@comment)
    end
    
  end


  describe "GET new" do
    
    def do_get
      get :new, :project_id => 'retro', :milestone_id => '1', :sprint_id => '37'
    end

    it_assigns_the_milestone
    it_assigns_the_sprint

    it "assigns a new story as @story" do
      @stories.should_receive(:new).and_return(@story)
      do_get
      assigns[:story].should equal(@story)
    end
  end


  describe "POST create" do
    before do
      @story.stub!(:save).and_return(false)
    end

    def do_post
      post :create, :project_id => 'retro', :milestone_id => '1', :sprint_id => '37', :story => {:these => 'params'}     
    end

    it_assigns_the_milestone(:do_post)
    it_assigns_the_sprint(:do_post)

    it "assigns a newly created story as @story" do
      @stories.should_receive(:new).with({'these' => 'params'}).and_return(@story)
      do_post
      assigns[:story].should equal(@story)
    end

    describe "with valid params" do
      
      it "redirects to story index" do
        @story.should_receive(:save).and_return(true)
        do_post
        response.should redirect_to(project_milestone_sprint_stories_path(@project, @milestone, @sprint))
      end
    end

    describe "with invalid params" do

      it "re-renders the 'new' template" do
        do_post
        response.should render_template('new')
      end
    
    end

  end


  describe "GET edit" do
    
    def do_get
      get :edit, :project_id => 'retro', :milestone_id => '1', :sprint_id => '37', :id => '73'
    end

    it_assigns_the_milestone
    it_assigns_the_sprint
    it_assigns_the_story

    it 'renders the edit template' do
      do_get
      response.should render_template(:edit)        
    end

  end
  
  describe "PUT update" do
    
    before do
      @story.stub!(:update_attributes).and_return(false)
    end
    
    def do_put
      put :update, :project_id => 'retro', :milestone_id => '1', :sprint_id => '37', :id => '73', :story => { 'attribute' => 'value' }
    end

    it_assigns_the_milestone(:do_put)
    it_assigns_the_sprint(:do_put)
    it_assigns_the_story(:do_put)

    it 'updates the story' do
      @story.should_receive(:update_attributes).with({ 'attribute' => 'value' })
      do_put
    end

    describe "with valid params" do
      
      it "redirects to story index" do
        @story.should_receive(:update_attributes).and_return(true)
        do_put
        response.should redirect_to(project_milestone_sprint_stories_path(@project, @milestone, @sprint))
      end
    end

    describe "with invalid params" do

      it "re-renders the 'edit' template" do
        do_put
        response.should render_template(:edit)
      end
    
    end

  end
  
  
  [:accept, :complete, :reopen].each do |action_name|

    describe "PUT #{action_name}" do
      
      before do
        @story.stub!(:save).and_return(false)
        @story.stub!("#{action_name}!".to_sym)
      end
      
      define_method :do_put do
        put action_name, :project_id => 'retro', :milestone_id => '1', :sprint_id => '37', :id => '73'
      end
  
      it_assigns_the_milestone(:do_put)
      it_assigns_the_sprint(:do_put)
      it_assigns_the_story(:do_put)
  
      it 'starts the #{action_name}! procedure' do
        @story.should_receive("#{action_name}!".to_sym)
        do_put
      end
  
      it 'redirects to stories' do
        @story.should_receive(:save).and_return(true)
        do_put
        response.should redirect_to(project_milestone_sprint_stories_path(@project, @milestone, @sprint))        
      end
  
    end
  
  end


  describe "POST comment" do
    
    before do
      @comment.stub!(:save).and_return(false)
    end
    
    def do_post
      post :comment, :project_id => 'retro', :milestone_id => '1', :sprint_id => '37', :id => '73', :story_comment => { :params => 'these' }
    end

    it_assigns_the_milestone(:do_post)
    it_assigns_the_sprint(:do_post)
    it_assigns_the_story(:do_post)

    it 'assigns the comment' do
      @comments.should_receive(:new).with({'params'=>'these'}).and_return(@comment)
      do_post
    end

    it 'renders the comment template' do
      @comment.should_receive(:save).and_return(true)
      do_post
      response.should render_template(:comment)        
    end

  end


  describe "PUT update_progress" do
    
    before do
      @progress_updates.stub!(:find_or_initialize).and_return(@progress_update)
      @progress_update.stub!(:save).and_return(false)
    end
    
    def do_put
      put :update_progress, :project_id => 'retro', :milestone_id => '1', :sprint_id => '37', :id => '73', :value => '60'
    end

    it_assigns_the_milestone(:do_put)
    it_assigns_the_sprint(:do_put)
    it_assigns_the_story(:do_put)

    it 'assigns the update' do
      @progress_updates.should_receive(:find_or_initialize).with(Time.zone.today, '60').and_return(@progress_update)
      do_put
    end

    describe 'if successful' do

      it 'renders the template' do
        @progress_update.should_receive(:save).and_return(true)
        do_put
        response.should render_template(:update_progress)        
      end

      it 'should reload the sprint' do
        @progress_update.stub!(:save).and_return(true)
        @sprints.should_receive(:find).twice.and_return(@sprint)
        do_put
      end

    end
    
    describe 'if not successful' do

      it 'should respond with error 422' do
        @progress_update.should_receive(:save).and_return(false)
        do_put
        response.code.should == '422'        
      end
    
      it 'should not reload the sprint' do
        @progress_update.stub!(:save).and_return(true)
        @sprints.should_receive(:find).once.and_return(@sprint)
        do_put
      end

    end

  end


  describe "PUT revise_hours" do
    
    before do
      @story.stub!(:revised_hours=)
      @story.stub!(:save).and_return(false)
    end
    
    def do_put
      put :revise_hours, :project_id => 'retro', :milestone_id => '1', :sprint_id => '37', :id => '73', :value => '24'
    end

    it_assigns_the_milestone(:do_put)
    it_assigns_the_sprint(:do_put)
    it_assigns_the_story(:do_put)

    describe 'if successful' do

      it 'renders the template' do
        @story.should_receive(:save).and_return(true)
        do_put
        response.should render_template(:revise_hours)        
      end

      it 'should reload the sprint' do
        @story.stub!(:save).and_return(true)
        @sprints.should_receive(:find).twice.and_return(@sprint)
        do_put
      end

    end
    
    describe 'if not successful' do

      it 'should respond with error 422' do
        do_put
        response.code.should == '422'        
      end
    
      it 'should not reload the sprint' do
        @sprints.should_receive(:find).once.and_return(@sprint)
        do_put
      end

    end

  end
end

