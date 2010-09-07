require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ProjectsController do

  before do 
    @user = stub_current_user! :name => 'Someone'
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
      @projects.stub!(:active).and_return(@projects)      
      @user.stub!(:projects).and_return(@projects)
      @user.stub!(:has_access?).and_return(true)
    end

    def do_get
      get :index
    end
  
    it 'should find all active projects for the logged-in user' do
      @user.should_receive(:projects).and_return(@projects)      
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
        @projects = []      
        @projects.stub!(:active).and_return(@projects)      
        @user.stub!(:projects).and_return(@projects)
      end
      
      def do_get
        get :index
      end

      describe 'and the user is a logged-in user' do      

        it_should_successfully_render_template('index')

        it 'should find all active projects for the logged-in user' do
          @user.should_receive(:projects).and_return(@projects)      
          do_get
        end

        it 'should assign no projects to the view' do
          do_get
          assigns[:projects].should == []
        end

      end

      
      describe 'and the user is a public user' do      
        before { @user.stub!(:public?).and_return(true) }
        
        it 'should redirect to login' do                  
          do_get
          response.should redirect_to(login_path)
        end        

      end
    end      


    describe 'if user has access to one project' do

      before do
        @project = mock_model(Project, :to_param => '1', :path_to_first_menu_item => '/projects/1/changesets')
        @projects = [@project]
        @projects.stub!(:active).and_return(@projects)      
        @user.stub!(:projects).and_return(@projects)
      end
      
      def do_get
        get :index        
      end

      it 'should load and assign all active user projects' do
        @user.should_receive(:projects).and_return(@projects)
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
        @projects.stub!(:active).and_return(@projects)      
        @user.stub!(:projects).and_return(@projects)
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
  

  describe 'GET /index.rss' do

    before do
      @changeset = stub_model(Changeset, :to_param => '123', :created_at => 2.days.ago)
      @ticket = stub_model(Ticket, :to_param => '456', :status => mock_model(Status, :name => 'Open'), :created_at => 2.hours.ago)
      
      @rss_item = mock('RssItems')
      @rss_items = mock('RssItems', :new_item => @rss_item)
      
      controller.stub!(:project_has_no_accessible_menu_items?).and_return(false)      
      
      @project_a = stub_model(Project, :to_param => 'retro', :name => 'Retro')
      @project_b = stub_model(Project, :to_param => 'sub', :name => 'Sub')

      @projects = [@project_a, @project_b]      
      @projects.stub!(:active).and_return(@projects)      
      @user.stub!(:projects).and_return(@projects)

      controller.stub!(:find_feedable_records).with(@project_a).and_return([@changeset])
      controller.stub!(:find_feedable_records).with(@project_b).and_return([@ticket])    
    end
    
    def do_get
      get :index, :format => 'rss'
    end

    it 'should load the feedable records' do
      controller.should_receive(:find_feedable_records).with(@project_a).and_return([@changeset])
      controller.should_receive(:find_feedable_records).with(@project_b).and_return([@ticket])
      do_get
    end

    it 'should sort and assign feedable records' do
      do_get
      assigns[:records].should == [
        [@ticket, @project_b],
        [@changeset, @project_a]
      ]
    end


    it 'should render RSS (with all records)' do
      do_get
      response.should have_tag('rss') do
        with_tag('channel') do
          with_tag('title', 'All Projects')
          with_tag('description', 'All news for all projects')
          with_tag('item', 2)
          with_tag('item link', 'http://test.host/projects/sub/tickets/456')
          with_tag('item link', 'http://test.host/projects/retro/changesets/123')
        end
      end
    end
        
  end


  describe 'GET /show' do

    before do
      @changeset = stub_model(Changeset, :to_param => '123')
      @ticket = stub_model(Ticket, :to_param => '456', :status => mock_model(Status, :name => 'Open'))
      
      controller.stub!(:find_feedable_records).and_return([@changeset, @ticket])
      controller.stub!(:project_has_no_accessible_menu_items?).and_return(false)
      
      @project  = mock_model Project, :to_param => 'retro', :name => 'Retro', :path_to_first_menu_item => '/projects/retro/changesets', :active? => true
      @projects = AssociationProxies::UserProjects.new([@project])
      @user.stub!(:projects).and_return(@projects)
    end

    def do_get(project_name, format = 'html')
      get :show, :id => project_name, :format => format
    end
    
    describe 'for HTML requests' do
                 
      it 'should redirect to the first available menu item' do
        do_get 'retro'
        response.should be_redirect
        response.should redirect_to(project_changesets_path(@project))        
      end

      describe 'if project is not accessible and other projects are present' do
        
        it 'should redirect to the projects overview page' do
          do_get 'other'
          response.should be_redirect
          response.should redirect_to(projects_path)        
        end
      
      end

      describe 'if project is not accessible and no other projects are present' do
        before do
          @projects = AssociationProxies::UserProjects.new
          @user.stub!(:projects).and_return(@projects)         
        end

        describe 'but project is does actually exist (just the user has no permission to see it)' do
                    
          it 'should fail authorization' do
            Project.should_receive(:find_by_short_name!).with('other').and_return(stub_model(Project))
            lambda { do_get 'other' }.should raise_error(Retrospectiva::AccessManager::NoAuthorizationError)
          end
        
        end

        describe 'and project is genuinely doesn\'t exist' do
                    
          it 'should fail with 404' do            
            lambda { do_get 'other' }.should raise_error(ActiveRecord::RecordNotFound)
          end
        
        end
                
      end
    end

    describe 'for RSS requests' do

      it 'should load the feedable records' do
        controller.should_receive(:find_feedable_records).with(@project).and_return([@changeset, @ticket])
        do_get  'retro', 'rss'
      end
  
      it 'should render RSS (with all feedable records)' do
        do_get  'retro', 'rss'
        response.should have_tag('rss') do
          with_tag('channel') do
            with_tag('title', 'Retro')
            with_tag('description', 'All news for Retro')
            with_tag('item', 2)
            with_tag('item link', 'http://test.host/projects/retro/tickets/456')
            with_tag('item link', 'http://test.host/projects/retro/changesets/123')
          end
        end
      end
      
    end

  end

  
  describe 'helper methods' do    

    describe 'find-feedable-records' do
      before do
        @c1, @c2 = stub_model(Changeset, :created_at => 2.days.ago, :to_param => '1'), stub_model(Changeset, :created_at => 2.hours.ago, :to_param => '2')
        @changesets = [@c1, @c2]
        @changesets.stub!(:feedable).and_return(@changesets)
        @project = stub_model(Project, :to_param => 'retro', :name => 'Retro', :changesets => @changesets)        
        @channels = { 'channel' => Changeset }
        controller.stub!(:load_channels).and_return(@channels)
      end
      
      def do_call
        controller.send :find_feedable_records, @project 
      end
      
      it 'should load feedable channels' do
        controller.should_receive(:load_channels).with(:feedable?, @project).and_return(@channels)
        do_call        
      end      

      it 'should load feedable records' do
        @project.should_receive(:changesets).and_return(@changesets)
        @changesets.should_receive(:feedable).and_return(@changesets)
        do_call        
      end      

      it 'should sort the records' do
        do_call.should == [@c2, @c1]        
      end      
      
    end
  
  end 
end
