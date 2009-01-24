require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProjectsController do

  before do 
    @user = mock_model(User, :public? => false, :time_zone => 'London')
    User.stub!(:current).and_return(@user)
  end
  
  describe 'loading active projects' do
    before do
      @menu_items = [
        mock_model(RetroAM::MenuMap::Item, :name => 'tickets', :path => '/projects/1/tickets'), 
        mock_model(RetroAM::MenuMap::Item, :name => 'changesets', :path => '/projects/1/changesets')
      ]

      @project = mock_model Project, 
        :enabled_menu_items => @menu_items, 
        :to_param => '1',
        :path_to_first_menu_item= => nil,
        :path_to_first_menu_item => '/projects/1/tickets'
      @projects = [@project]
      @user.stub!(:active_projects).and_return(@projects)
      @user.stub!(:has_access?).and_return(true)
    end

    def do_get
      get :index
    end
  
    it 'should find all active projects for the logged-in user' do
      @user.should_receive(:active_projects).and_return(@projects)      
      do_get
    end

    describe 'if no menu-items are accessible by the user' do
  
      it 'should remove the project from the available list' do
        @user.should_receive(:has_access?).with('/projects/1/tickets').and_return(false)
        @user.should_receive(:has_access?).with('/projects/1/changesets').and_return(false)
        do_get
        assigns[:projects].should have(:no).records
      end      
      
    end

    describe 'if at least one menu-item is accessible by the user' do
  
      it 'should keep the project in the available list' do
        @user.should_receive(:has_access?).with('/projects/1/tickets').and_return(false)
        @user.should_receive(:has_access?).with('/projects/1/changesets').and_return(true)
        do_get
        assigns[:projects].should have(1).record
      end      

      it 'should stop searching after the first accessible menu-item was found' do
        @user.should_receive(:has_access?).with('/projects/1/tickets').and_return(true)
        @user.should_not_receive(:has_access?).with('/projects/1/changesets')
        do_get
      end      

      it 'should assign the first available menu-item path to the project' do
        @project.should_receive(:path_to_first_menu_item=).with('/projects/1/tickets')
        do_get
      end      
      
    end
    
  end  
  
  
  describe 'GET /index' do
    before do 
      controller.stub!(:project_has_no_accessible_menu_items?).and_return(false)
    end

    describe 'if user has no access to projects' do

      before do
        @user.stub!(:active_projects).and_return([])
      end
      

      describe 'and the user is a logged-in user' do      

        def do_get
          get :index
        end

        it_should_successfully_render_template('index')

        it 'should find all active projects for the logged-in user' do
          @user.should_receive(:active_projects).and_return([])      
          do_get
        end

        it 'should assign no projects to the view' do
          do_get
          assigns[:projects].should == []
        end

      end

      
      describe 'and the user is a public user' do      

        before do
          @user.should_receive(:public?).and_return(true)        
        end        

        def do_get
          get :index
        end

        it 'should redirect to login' do
          do_get
          response.should be_redirect
          response.should redirect_to(login_path)
        end        

      end

    end      


    describe 'if user has access to one project' do

      before do
        @project = mock_model(Project, :to_param => '1', :path_to_first_menu_item => '/projects/1/changesets')
        @projects = [@project]
        @user.stub!(:active_projects).and_return(@projects)
      end
      
      def do_get
        get :index        
      end

      it 'should load and assign all active user projects' do
        @user.should_receive(:active_projects).and_return(@projects)
        do_get
        assigns[:projects].should have(1).record
      end

      it 'should reject all projects have no accessible menu-items' do
        controller.should_receive(:project_has_no_accessible_menu_items?).with(@project).and_return(false)
        do_get
      end
      
      it 'should redirect to this project' do
        do_get
        response.should redirect_to(project_changesets_path(@project))
      end

    end      


    describe 'if user has access to multiple projects' do

      before do
        @projects = [mock_model(Project), mock_model(Project)]
        @user.stub!(:active_projects).and_return(@projects)
      end

      def do_get
        get :index
      end

      it_should_successfully_render_template('index')

      it 'should assign the projects for the view' do
        do_get
        assigns[:projects].should == @projects
        assigns[:projects].should have(2).records
      end
      
    end            
  end
  
  
  
  describe 'GET /show' do

    before do 
      controller.stub!(:project_has_no_accessible_menu_items?).and_return(false)
    end

    before do
      @projects = [mock_model(Project, :to_param => '1', :path_to_first_menu_item => '/projects/1/changesets')]
      @user.should_receive(:active_projects).and_return(@projects)
    end

    def do_get(project_name)
      get :show, :id => project_name
    end
    
    describe 'when the project can be found for the logged-in user' do
           
      it 'should redirect to the first available menu item' do
        @projects.should_receive(:find).with('retrospectiva').and_return(@projects.first)      
        do_get 'retrospectiva'
        response.should be_redirect
        response.should redirect_to(project_changesets_path(@projects.first))        
      end

    end

    describe 'when the project cannot be found for the logged-in user' do

      it 'should redirect to index' do
        @projects.should_receive(:find).with('non-existing').and_return(nil)
        do_get 'non-existing'
        response.should be_redirect
        response.should redirect_to(projects_path)
      end

    end    

  end
  
end
