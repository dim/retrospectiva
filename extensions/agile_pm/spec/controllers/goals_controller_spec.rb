require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GoalsController do
  it_should_behave_like EveryProjectAreaController

  before do
    @milestone = mock_model(Milestone)
    @milestones = [@milestone]
    @milestones.stub!(:in_default_order).and_return(@milestones)
    @milestones.stub!(:in_order_of_relevance).and_return(@milestones)
    @milestones.stub!(:all).and_return(@milestones)
    @milestones.stub!(:find).with('1', :include=>[:sprints, :goals], :order=>"goals.priority_id DESC, goals.title").and_return(@milestone)
    
    @sprint = mock_model(Sprint, :title => 'Sprint 1')
    @sprints = [@sprint]
    @sprints.stub!(:in_order_of_relevance).and_return(@sprints)
    @sprints.stub!(:all).and_return(@sprints)
    
    @goal = mock_model(Goal, :sprint => @sprint)
    @goals = [@goal]
    @goals.stub!(:find).with('37', :include=>[:sprint, :stories], :order=>"stories.title").and_return(@goal)

    @user = mock_model(User)
    @users = [@user]
    @users.stub!(:with_permission).and_return(@users)
    
    @milestone.stub!(:sprints).and_return(@sprints)    
    @milestone.stub!(:goals).and_return(@goals)        
    
    @project = permit_access_with_current_project! :milestones => @milestones, :users => @users, :name => 'Retrospectiva'    
  end

  class << self
    
    def it_assigns_the_milestone(method = :do_get)
      it "assigns milestone as @milestone" do
        @milestones.should_receive(:find).with('1', :include=>[:sprints, :goals], :order=>"goals.priority_id DESC, goals.title").and_return(@milestone)
        send(method)
        assigns[:milestone].should == @milestone
      end
    end
    
  end    

  describe "GET home" do
    
    def do_get
      get :home, :project_id => 'retro' 
    end

    it "assigns current milestone as @milestone" do
      @milestones.should_receive(:in_order_of_relevance).and_return(@milestones)      
      do_get
      assigns[:milestone].should == @milestone
    end

    it "redirects to milestone if found" do
      @milestones.stub!(:in_order_of_relevance).and_return(@milestones)      
      do_get
      response.should redirect_to(project_milestone_goals_path(Project.current, @milestone))
    end
      
    it "show no-milestone page if not milestone is found" do
      @milestones.stub!(:in_order_of_relevance).and_return([])      
      do_get
      response.should render_template(:no_milestones)
    end
    
  end

  
  describe "GET index" do
    
    def do_get
      get :index, :project_id => 'retro', :milestone_id => '1' 
    end
    
    it_assigns_the_milestone

    it "assigns all milestones as @milestones" do
      @milestones.should_receive(:in_default_order).and_return(@milestones)
      do_get
      assigns[:milestones].should == @milestones
    end

    it "assigns current sprint as @current_sprint" do
      do_get
      assigns[:current_sprint].should == @sprint
    end
    
    it "assigns all goals indexed as @goals" do
      do_get
      assigns[:goals].should == { @sprint => [@goal] }
    end

  end

  describe "GET show" do
    def do_get
      get :show, :project_id => 'retro', :milestone_id => '1', :id => '37' 
    end

    it_assigns_the_milestone

    it "assigns the requested goal as @goal" do
      @goals.should_receive(:find).with("37", :include=>[:sprint, :stories], :order=>"stories.title").and_return(@goal)    
      do_get
      assigns[:goal].should equal(@goal)
    end
  end

  describe "GET new" do
    before do 
      @new_goal = stub_model(Goal)
      @goals.stub!(:new).and_return(@new_goal)    
    end
    
    def do_get
      get :new, :project_id => 'retro', :milestone_id => '1', :sprint_id => '37'
    end

    it_assigns_the_milestone

    it "assigns a new goal as @goal" do
      @goals.should_receive(:new).with(:requester_id=>0, :sprint_id=>'37').and_return(@new_goal)
      do_get
      assigns[:goal].should equal(@new_goal)
    end
  end

  describe "GET edit" do
    def do_get
      get :edit, :project_id => 'retro', :milestone_id => '1', :id => '37' 
    end

    it_assigns_the_milestone

    it "assigns the requested goal as @goal" do
      @goals.should_receive(:find).and_return(@goal)    
      do_get
      assigns[:goal].should equal(@goal)
    end
  end

  describe "POST create" do

    def do_post
      post :create, :project_id => 'retro', :milestone_id => '1', :goal => {:these => 'params'}     
    end

    describe "with valid params" do
      before do
        @goal.stub!(:save).and_return(true)
      end
      
      it "assigns a newly created goal as @goal" do
        @goals.stub!(:new).with({'these' => 'params'}).and_return(@goal)
        do_post
        assigns[:goal].should equal(@goal)
      end

      it "redirects to the created goal" do
        @goals.stub!(:new).and_return(@goal)
        do_post
        response.should redirect_to(project_milestone_goals_path(@project, @milestone, :anchor => 'sprint-1'))
      end
    end

    describe "with invalid params" do
      before do
        @goal.stub!(:save).and_return(false)
      end

      it "assigns a newly created but unsaved goal as @goal" do
        @goals.stub!(:new).with({'these' => 'params'}).and_return(@goal)
        do_post
        assigns[:goal].should equal(@goal)
      end

      it "re-renders the 'new' template" do
        @goals.stub!(:new).and_return(@goal)
        do_post
        response.should render_template('new')
      end
    end

  end


  describe "PUT update" do
    before do
      @goal.stub!(:update_attributes).and_return(true)      
    end
    
    def do_put
      put :update, :project_id => 'retro', :milestone_id => '1', :id => "37", :goal => {:these => 'params'}
    end
    
    describe "with valid params" do
      it "assigns the requested goal as @goal" do
        @goals.should_receive(:find).and_return(@goal)    
        do_put
        assigns[:goal].should equal(@goal)
      end

      it "updates the requested goal and redirect" do
        @goals.stub!(:find).and_return(@goal)    
        @goal.should_receive(:update_attributes).with({'these' => 'params'}).and_return(true)
        do_put
        response.should redirect_to(project_milestone_goals_path(@project, @milestone, :anchor => 'sprint-1'))
      end
    end

    describe "with invalid params" do
      it "assigns the requested goal as @goal" do
        @goals.should_receive(:find).and_return(@goal)    
        do_put
        assigns[:goal].should equal(@goal)
      end

      it "re-renders the 'edit' template" do
        @goals.stub!(:find).and_return(@goal)    
        @goal.should_receive(:update_attributes).with({'these' => 'params'}).and_return(false)
        do_put
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
    def do_delete
      delete :destroy, :project_id => 'retro', :milestone_id => '1', :id => '37' 
    end
    
    it "destroys the requested goal" do
      @goals.should_receive(:find).and_return(@goal)    
      @goal.should_receive(:destroy)
      do_delete      
    end

    it "redirects to the goals list" do
      @goal.stub!(:destroy)
      do_delete      
      response.should redirect_to(project_milestone_goals_path(@project, @milestone))
    end
  end

end
