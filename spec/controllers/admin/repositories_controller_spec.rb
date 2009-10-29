require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::RepositoriesController do
  it_should_behave_like EveryAdminAreaController
  
  before do
    permit_access!
    @repositories = [mock_model(Repository), mock_model(Repository)]
  end

  describe "handling GET /admin/repositories" do

    before(:each) do
      Repository.stub!(:find).and_return(@repositories)
    end

    def do_get
      get :index      
    end

    it_should_successfully_render_template('index')
  
    it "should find repository records" do
      Repository.should_receive(:find).
        with(:all, :order => 'name', :offset => 0, :limit => Repository.per_page).
        and_return(@repositories)
      do_get
    end

    it "should assign the found records for the view" do
      do_get
      assigns[:repositories].should == @repositories.paginate
    end

  end
  



  describe "handling GET /admin/repositories/new" do

    before(:each) do
      @repository = mock_model(Repository::Git)
      Repository::Git.stub!(:new).and_return(@repository)
    end

    def do_get
      get :new      
    end

    it_should_successfully_render_template('new')
    
    it "should create an new repository" do
      Repository::Git.should_receive(:new).and_return(@repository)
      do_get
    end
  
    it "should not save the new repository" do
      @repository.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new repository for the view" do
      do_get
      assigns[:repository].should equal(@repository)
    end

  end




  describe "handling GET /admin/repositories/1/edit" do

    before(:each) do
      @repository = mock_model(Repository)
      Repository.stub!(:find).and_return(@repository)
    end
  
    def do_get
      get :edit, :id => "1"      
    end
  
    it "should find the repository requested" do
      Repository.should_receive(:find).with('1').and_return(@repository)
      do_get
    end
  
    it "should assign the found repository for the view" do
      do_get
      assigns[:repository].should equal(@repository)
    end

    it_should_successfully_render_template('edit')

  end




  describe "handling POST /admin/repositories" do

    before(:each) do
      @repository = mock_model(Repository::Subversion, :to_param => "1")
      Repository::Subversion.stub!(:new).and_return(@repository)
    end
    
    describe "with successful save" do
  
      def do_post
        @repository.should_receive(:save).and_return(true)
        post :create, :repository => { :kind => 'Subversion' }
      end
  
      it "should create a new repository" do
        Repository::Subversion.should_receive(:new).with({ 'kind' => 'Subversion' }).and_return(@repository)
        do_post
      end

      it "should redirect to the repository list" do
        do_post
        response.should redirect_to(admin_repositories_path)
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @repository.should_receive(:save).and_return(false)
        post :create, :repository => { :kind => 'Subversion' }
      end

      it_should_successfully_render_template('new', :do_post)

    end
  end




  describe "handling PUT /admin/repositories/1" do

    before(:each) do
      @repository = mock_model(Repository, :to_param => "1")
      Repository.stub!(:find).and_return(@repository)
    end

    describe "with successful update" do

      def do_put
        @repository.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the repository requested" do
        Repository.should_receive(:find).with("1").and_return(@repository)
        do_put
        assigns(:repository).should equal(@repository)
      end

    end    
    
    describe "with failed update" do

      def do_put
        @repository.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it_should_successfully_render_template('edit', :do_put)

    end
  end




  describe "handling DELETE /repositories/1" do

    before(:each) do
      @repository = mock_model(Repository, :to_param => "1", :destroy => true)
      Repository.stub!(:find).and_return(@repository)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find and destroy the repository requested" do
      @repository.should_receive(:destroy).and_return(true)
      do_delete
    end
  
    it "should redirect to the repositories list" do
      do_delete
      response.should redirect_to(admin_repositories_path)
    end
  end



  describe "handling XHR-GET /repositories/validate" do
    
    before do
      File.stub!(:exists?).and_return(true)
      File.stub!(:readable?).and_return(true)
      File.stub!(:executable?).and_return(true)      
      Repository::Subversion.stub!(:enabled?).and_return(true)
      
      @repository = mock_model(Repository::Abstract, :active? => true, :latest_revision => 'R10')
      Repository.stub!(:[]).and_return(Repository::Subversion)
      Repository::Subversion.stub!(:new).and_return(@repository)
    end
    
    it 'should reject non-ajax requests' do
      get :validate
      response.code.should == '400'
    end

    def do_get
      xhr :get, :validate, :kind => 'Subversion', :path => '/home/me/repositories/project'
    end

    it 'should handle invalid repository types' do
      Repository.should_receive(:[]).with('Subversion').and_return(nil)
      do_get
      response.body.should match(/Support for Subversion is not enabled/)
    end

    it 'should handle disabled repository types' do
      Repository::Subversion.should_receive(:enabled?).and_return(false)
      do_get
      response.body.should match(/Support for Subversion is not enabled/)
    end

    it 'should return correct message if path doesn\'t exist' do
      File.should_receive(:exists?).with('/home/me/repositories/project').and_return(false)
      do_get
      response.body.should match(/Path does not exist/)
    end

    it 'should return correct message if path is not accessible' do
      File.should_receive(:readable?).with('/home/me/repositories/project').and_return(false)
      do_get
      response.body.should match(/You are not permitted to browse this path/)
    end

    it 'should build a new repository using the given kind' do
      Repository.should_receive(:[]).with('Subversion').and_return(Repository::Subversion)
      Repository::Subversion.should_receive(:new).with(:path => '/home/me/repositories/project').and_return(@repository)
      do_get
    end

    it 'should return a successs message if repository matches the path' do
      do_get
      response.body.should match(/Success/)
    end

    it 'should return a failure message if path does not contain a repository' do
      @repository.should_receive(:active?).and_return(false)
      do_get
      response.body.should match(/Failure/)
    end
    
  end


end
