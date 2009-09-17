require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MilestonesController do
  it_should_behave_like EveryProjectAreaController

  before do
    @milestones = [mock_model(Milestone)]
    @project = permit_access_with_current_project! :milestones => @milestones, :name => 'Retrospectiva'
    @milestones.stub!(:count)
    @milestones.stub!(:maximum)
  end

  describe "handling GET /milestones" do
    before(:each) do
      @milestones.stub!(:in_default_order).and_return(@milestones)
      @milestones.stub!(:active_on).and_return(@milestones)
      @milestones.stub!(:paginate).and_return(@milestones)
    end
  
    def do_get(options = {})
      get :index, options.merge(:project_id => @project.to_param)
    end
  
    it_should_successfully_render_template('index')
      
    describe 'by default' do

      it 'should check freshness' do
        @milestones.should_receive(:count).and_return(5)
        @milestones.should_receive(:maximum).with(:updated_at)
        do_get
      end
      
      it "should find active milestones" do
        @milestones.should_receive(:in_default_order).with().and_return(@milestones)
        @milestones.should_receive(:active_on).with(Date.today).and_return(@milestones)
        @milestones.should_receive(:paginate).with(
          :per_page=>nil, :total_entries=>nil, :page=>nil, 
          :include => {:tickets => :status}
        ).and_return(@milestones)
        do_get
      end

    end

    describe 'if completed milestones were requested' do
    
      it "should find all milestones" do
        @milestones.should_not_receive(:active_on)
        @milestones.should_receive(:paginate).with(
          :per_page=>nil, :total_entries=>nil, :page=>nil, 
          :include => {:tickets => :status}
        ).and_return(@milestones)
        do_get :completed => '1'
      end

    end
    
    it "should assign the found milestones for the view" do
      do_get
      assigns[:milestones].should == @milestones
    end
  end

  describe "handling GET /milestones.rss" do
    before(:each) do
      @milestones.stub!(:in_default_order).and_return(@milestones)
      @milestones.stub!(:active_on).and_return(@milestones)
      @milestones.stub!(:paginate).and_return(@milestones)
      Milestone.stub!(:to_rss).and_return("RSS")
    end
    
    def do_get(options = {})
      get :index, options.merge(:format => 'rss', :project_id => @project.to_param)      
    end
    
    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find milestones" do
      @milestones.should_receive(:active_on).with(Date.today).and_return(@milestones)
      @milestones.should_receive(:paginate).with(
        :per_page=>10, :total_entries=>10, :page=>1, 
        :include => {:tickets => :status}
      ).and_return(@milestones)
      do_get
    end

    it "should render the found milestones as RSS" do
      Milestone.should_receive(:to_rss).with(@milestones, {}).and_return("RSS")
      do_get :completed => '1'
      response.body.should == "RSS"
      response.content_type.should == "application/rss+xml"
    end
  end

  describe "handling GET /milestones/new" do

    before(:each) do
      @milestone = mock_model(Milestone)
      @milestones.stub!(:new).and_return(@milestone)
    end
  
    def do_get
      get :new, :project_id => @project.to_param
    end
    
    it_should_successfully_render_template('new')

    it "should create an new milestone" do
      @milestones.should_receive(:new).and_return(@milestone)
      do_get
    end
  
    it "should not save the new milestone" do
      @milestone.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new milestone for the view" do
      do_get
      assigns[:milestone].should equal(@milestone)
    end
  end


  describe "handling GET /milestones/1/edit" do

    before(:each) do
      @milestone = mock_model(Milestone)
      @milestones.stub!(:find).and_return(@milestone)
    end
  
    def do_get
      get :edit, :project_id => @project.to_param, :id => "1"
    end

    it_should_successfully_render_template('edit')
  
    it "should find the milestone requested" do
      @milestones.should_receive(:find).and_return(@milestone)
      do_get
    end
  
    it "should assign the found Milestone for the view" do
      do_get
      assigns[:milestone].should equal(@milestone)
    end
  end

  describe "handling POST /milestones" do

    before(:each) do
      @milestone = mock_model(Milestone, :to_param => "1")
      @milestones.stub!(:new).and_return(@milestone)
    end
    
    describe "with successful save" do
  
      def do_post
        @milestone.should_receive(:save).and_return(true)
        post :create, :project_id => @project.to_param, :milestone => {}
      end
  
      it "should create a new milestone" do
        @milestones.should_receive(:new).with({}).and_return(@milestone)
        do_post
      end

      it "should redirect to the milestones list" do
        do_post
        response.should redirect_to(project_milestones_path(@project))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @milestone.should_receive(:save).and_return(false)
        post :create, :project_id => @project.to_param, :milestone => {}
      end
  
      it_should_successfully_render_template('new', :do_post)
      
    end
  end

  describe "handling PUT /milestones/1" do

    before(:each) do
      @milestone = mock_model(Milestone, :to_param => "1")
      @milestones.stub!(:find).and_return(@milestone)
    end
    
    describe "with successful update" do

      def do_put
        @milestone.should_receive(:update_attributes).and_return(true)
        put :update, :project_id => @project.to_param, :id => "1"
      end

      it "should find the milestone requested" do
        @milestones.should_receive(:find).with("1").and_return(@milestone)
        do_put
      end

      it "should update the found milestone" do
        do_put
        assigns(:milestone).should equal(@milestone)
      end

      it "should redirect to the milestones list" do
        do_put
        response.should redirect_to(project_milestones_url(@project))
      end

    end
    
    describe "with failed update" do

      def do_put
        @milestone.should_receive(:update_attributes).and_return(false)
        put :update, :project_id => @project.to_param, :id => "1"
      end

      it_should_successfully_render_template('edit', :do_put)

    end
  end

  describe "handling DELETE /milestones/1" do

    before(:each) do
      @milestone = mock_model(Milestone, :to_param => "1", :destroy => true)
      @milestones.stub!(:find).and_return(@milestone)
    end
  
    def do_delete
      delete :destroy, :project_id => @project.to_param, :id => "1"
    end

    it "should find the milestone" do
      @milestones.should_receive(:find).with("1").and_return(@milestone)
      do_delete
    end

    it "should destroy the milestone" do
      @milestone.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the milestones list" do
      do_delete
      response.should redirect_to(project_milestones_url(@project))
    end
  end
end
