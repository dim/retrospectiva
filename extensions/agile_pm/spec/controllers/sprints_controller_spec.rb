require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SprintsController do
  it_should_behave_like EveryProjectAreaController

  before do
    @sprint = mock_model(Sprint, :title => 'Sprint 1')
    @sprints = [@sprint]
    @sprints.stub!(:find).with('37').and_return(@sprint)
    @sprints.stub!(:new).and_return(@sprint)

    @milestone = mock_model(Milestone)
    @milestone.stub!(:sprints).and_return(@sprints)    

    @milestones = [@milestone]
    @milestones.stub!(:find).with('1').and_return(@milestone)
    
    @project = permit_access_with_current_project! :milestones => @milestones, :name => 'Retrospectiva'    
  end

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
        @sprints.should_receive(:find).with("37").and_return(@sprint)    
        send(method)
        assigns[:sprint].should equal(@sprint)
      end
    end
    
  end    


  describe "GET show" do
    
    def do_get
      get :show, :project_id => 'retro', :milestone_id => '1', :id => '37' 
    end
    
    it_assigns_the_milestone
    it_assigns_the_sprint
  
  end


  describe "GET new" do
    
    def do_get
      get :new, :project_id => 'retro', :milestone_id => '1' 
    end
    
    it_assigns_the_milestone

    it "assigns a new sprint as @sprint" do
      @sprints.should_receive(:new).with(:title => 'Sprint ').and_return(@sprint)
      do_get
      assigns[:sprint].should equal(@sprint)
    end

  end


  describe "GET edit" do

    def do_get
      get :edit, :project_id => 'retro', :milestone_id => '1', :id => '37' 
    end

    it_assigns_the_milestone
    it_assigns_the_sprint

  end


  describe "POST create" do
    before do
      @sprint.stub!(:save).and_return(true)
    end

    def do_post
      post :create, :project_id => 'retro', :milestone_id => '1', :sprint => {:these => 'params'}
    end

    it_assigns_the_milestone(:do_post)

    describe "with valid params" do
      
      it "assigns a newly created sprint as @sprint" do
        @sprint.stub!(:new).with({'these' => 'params'}).and_return(@sprint)
        do_post
        assigns[:sprint].should equal(@sprint)
      end

      it "redirects to the created sprint" do
        @sprint.stub!(:new).and_return(@sprint)
        do_post
        response.should redirect_to(project_milestone_goals_path(@project, @milestone, :anchor => 'sprint-1'))
      end
    end

    describe "with invalid params" do

      it "assigns a newly created but unsaved sprint as @sprint" do
        @sprints.stub!(:new).with({'these' => 'params'}).and_return(@sprint)
        @sprint.stub!(:save).and_return(false)
        do_post
        assigns[:sprint].should equal(@sprint)
      end

      it "re-renders the 'new' template" do
        @sprints.stub!(:new).and_return(@sprint)
        @sprint.stub!(:save).and_return(false)
        do_post
        response.should render_template('new')
      end
    end

  end


  describe "PUT update" do
    
    before do
      @sprint.stub!(:update_attributes).and_return(false)      
    end
    
    def do_put
      put :update, :project_id => 'retro', :milestone_id => '1', :id => "37", :sprint => {:these => 'params'}
    end
    
    it_assigns_the_milestone(:do_put)
    it_assigns_the_sprint(:do_put)
    
    describe "with valid params" do
      it "updates the requested goal and redirect" do
        @sprint.should_receive(:update_attributes).with({'these' => 'params'}).and_return(true)
        do_put
        response.should redirect_to(project_milestone_goals_path(@project, @milestone, :anchor => 'sprint-1'))
      end
    end

    describe "with invalid params" do
      it "re-renders the 'edit' template" do
        do_put
        response.should render_template('edit')
      end
    end

  end


  describe "DELETE destroy" do
    
    before do
      @sprint.stub!(:destroy)
    end
    
    def do_delete
      delete :destroy, :project_id => 'retro', :milestone_id => '1', :id => '37' 
    end

    it_assigns_the_milestone(:do_delete)
    it_assigns_the_sprint(:do_delete)
    
    it "destroys the requested sprint" do
      @sprint.should_receive(:destroy)
      do_delete      
    end

    it "redirects to the goals list" do
      do_delete      
      response.should redirect_to(project_milestone_goals_path(@project, @milestone))
    end

  end

end
