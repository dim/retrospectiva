require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ProjectsController do
  it_should_behave_like EveryAdminAreaController
  
  before do
    permit_access!
    @projects = [mock_model(Project), mock_model(Project)]
    Repository.stub!(:find).and_return([])
  end

  describe "handling GET /admin/projects" do

    before(:each) do
      Project.stub!(:find).and_return(@projects)
    end
  
    def do_get
      get :index      
    end
    
    it_should_successfully_render_template('index')
    
    it "should find project records" do
      Project.should_receive(:find).
        with(:all, :order => 'name',
        :offset => 0, :limit => Project.per_page).
        and_return(@projects)
      do_get
    end

    it "should assign the found records for the view" do
      do_get
      assigns[:projects].should == @projects.paginate
    end

  end
  



  describe "handling GET /admin/projects/new" do

    before(:each) do
      @project = mock_model(Project)
      Project.stub!(:new).and_return(@project)
      Repository.stub!(:find_by_short_name!).and_return([])
    end

    def do_get
      get :new      
    end
    
    it_should_successfully_render_template('new')
  
    it "should create an new project" do
      Project.should_receive(:new).and_return(@project)
      do_get
    end
  
    it "should not save the new project" do
      @project.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new project for the view" do
      do_get
      assigns[:project].should equal(@project)
    end

    it "should pre-load the repository records" do
      Repository.should_receive(:find).and_return([])
      do_get
      assigns[:repositories].should == []
    end
    
  end


  describe "handling GET /admin/projects/1/edit" do

    before(:each) do
      @project = mock_model(Project)
      Project.stub!(:find_by_short_name!).and_return(@project)
      Repository.stub!(:find).and_return([])
    end
  
    def do_get
      get :edit, :id => "1"      
    end
  
    it "should find the project requested" do
      Project.should_receive(:find_by_short_name!).with('1').and_return(@project)
      do_get
    end
  
    it "should assign the found project for the view" do
      do_get
      assigns[:project].should equal(@project)
    end

    it_should_successfully_render_template('edit')

    it "should pre-load the repository records" do
      Repository.should_receive(:find).and_return([])
      get :new
      assigns[:repositories].should == []
    end
    
  end




  describe "handling POST /admin/projects" do

    before(:each) do
      @project = mock_model(Project, :to_param => "1")
      Project.stub!(:new).and_return(@project)
      Repository.stub!(:find).and_return([])
    end
    
    describe "with successful save" do
  
      def do_post
        @project.should_receive(:save).and_return(true)
        post :create, :project => {}
      end
  
      it "should create a new project" do
        Project.should_receive(:new).with({}).and_return(@project)
        do_post
      end

      it "should not pre-load the repository records" do
        Repository.should_not_receive(:find)
        do_post
      end

      it "should redirect to the project list" do
        do_post
        response.should redirect_to(admin_projects_path)
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @project.should_receive(:save).and_return(false)
        post :create, :project => {}
      end

      it_should_successfully_render_template('new', :do_post)
  
      it "should pre-load the repository records" do
        Repository.should_receive(:find).and_return([])
        get :new
        assigns[:repositories].should == []
      end
      
    end
  end




  describe "handling PUT /admin/projects/1" do

    before(:each) do
      @project = mock_model(Project, :to_param => "1")
      Project.stub!(:find_by_short_name!).and_return(@project)
      Repository.stub!(:find).and_return([])
    end

    describe "with successful update" do

      def do_put
        @project.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the project requested" do
        Project.should_receive(:find_by_short_name!).with("1").and_return(@project)
        do_put
        assigns(:project).should equal(@project)
      end

      it "should not pre-load the repository records" do
        Repository.should_not_receive(:find)
        do_put
      end

    end    
    
    describe "with failed update" do

      def do_put
        @project.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it_should_successfully_render_template('edit', :do_put)

      it "should pre-load the repository records" do
        Repository.should_receive(:find).and_return([])
        get :new
        assigns[:repositories].should == []
      end
      
    end
  end




  describe "handling DELETE /projects/1" do

    before(:each) do
      @project = mock_model(Project, :to_param => "1", :destroy => true)
      Project.stub!(:find_by_short_name!).and_return(@project)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find and destroy the project requested" do
      Project.should_receive(:find_by_short_name!).and_return(@project)
      @project.should_receive(:destroy).and_return(true)
      do_delete
    end
  
    it "should redirect to the projects list" do
      do_delete
      response.should redirect_to(admin_projects_path)
    end
  end



  
  describe "handling XHR-GET /projects/repository_validation" do
    
    it 'should reject non-ajax requests' do
      get :repository_validation
      response.code.should == '400'
    end

    it 'should verify that a repository is selected' do
      xhr :get, :repository_validation
      response.body.should match(/No repository selected/)
    end

    describe 'if all parameters are provided' do
      
      before do
        @repository = mock_model(Repository)
        @node = mock_model(Repository::Abstract::Node, :dir? => true)
        Repository.stub!(:find).and_return(@repository)
        @repository.stub!(:node).and_return(@node)
      end
      
      def do_get
        xhr :get, :repository_validation, :repository_id => '1', :root_path => 'trunk/'
      end
      
      it 'should try to find the repository' do
        Repository.should_receive(:find).and_return(@repository)
        do_get
      end
      
      it 'should try to find the repository node' do
        @repository.should_receive(:node).with('trunk/').and_return(@node)
        do_get
      end

      it 'should confirm success if found node is a directory' do
        do_get
        response.body.should match(/Success/)
      end

      it 'should return failure message if node is not found or not a directory' do
        @node.should_receive(:dir?).and_return(false)
        do_get
        response.body.should match(/Failure/)
      end

    end
    
  end


end
