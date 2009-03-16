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
  

  describe 'GET /index.rss' do

    before do
      @changeset = stub_model(Changeset, :to_param => '123', :created_at => 2.days.ago)
      @ticket = stub_model(Ticket, :to_param => '456', :status => mock_model(Status, :name => 'Open'), :created_at => 2.hours.ago)
      
      @rss_item = mock('RssItems')
      @rss_items = mock('RssItems', :new_item => @rss_item)
      
      controller.stub!(:project_has_no_accessible_menu_items?).and_return(false)      
      controller.stub!(:render_rss).and_yield(@rss_items)
      
      @project_a = stub_model(Project, :to_param => 'retro', :name => 'Retro')
      @project_b = stub_model(Project, :to_param => 'sub', :name => 'Sub')
      @user.stub!(:active_projects).and_return([@project_a, @project_b])      

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


    it 'should convert feedable records to RSS' do
      @ticket.should_receive(:to_rss).with(@rss_item, :project => @project_b)
      @changeset.should_receive(:to_rss).with(@rss_item, :project => @project_a)
      do_get
    end

    it 'should render RSS' do
      controller.should_receive(:render_rss).
        with('All Projects', 'All news for all projects', 'http://test.host/projects').
        and_yield(@rss_items)
      do_get
    end
        
  end


  describe 'GET /show' do

    before do
      controller.stub!(:project_has_no_accessible_menu_items?).and_return(false)
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

  
  describe 'GET /show.rss' do

    before do
      @changeset = stub_model(Changeset, :to_param => '123')
      @ticket = stub_model(Ticket, :to_param => '456', :status => mock_model(Status, :name => 'Open'))
      
      @rss_item = mock('RssItems')
      @rss_items = mock('RssItems', :new_item => @rss_item)
      
      controller.stub!(:project_has_no_accessible_menu_items?).and_return(false)      
      controller.stub!(:render_rss).and_yield(@rss_items)
      controller.stub!(:find_feedable_records).and_return([@changeset, @ticket])
      
      @project = stub_model(Project, :to_param => 'retro', :name => 'Retro')
      @projects = [@project]
      @projects.stub!(:find).and_return(@project)

      @user.stub!(:active_projects).and_return(@projects)      
    end
    
    def do_get
      get :show, :id => @project.to_param, :format => 'rss'
    end

    it 'should find the project' do
      @projects.should_receive(:find).with('retro').and_return(@project)
      do_get
    end

    it 'should load the feedable records' do
      controller.should_receive(:find_feedable_records).with(@project).and_return([@changeset, @ticket])
      do_get
    end

    it 'should convert feedable records to RSS' do
      @ticket.should_receive(:to_rss).with(@rss_item, :project => @project)
      @changeset.should_receive(:to_rss).with(@rss_item, :project => @project)
      do_get
    end

    it 'should render RSS' do
      controller.should_receive(:render_rss).
        with('Retro', 'All news for Retro', 'http://test.host/projects/retro').
        and_yield(@rss_items)
      do_get
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


    describe 'render-rss' do
      before do
        controller.stub!(:render)
        @changeset = stub_model(Changeset, :created_at => Time.utc(2009, 1, 1), :to_param => '1')
        @project = stub_model(Project, :to_param => 'retro', :name => 'Retro')        
      end
      
      def do_call
        controller.send :render_rss, 'Title', 'Description', 'http://test.com/project/retro.rss' do |items|
          @changeset.to_rss(items.new_item, :project => @project)
        end
      end
      
      it 'should render rss' do
        controller.should_receive(:render).with(
          :xml => '<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
  xmlns:trackback="http://madskills.com/public/xml/rss/module/trackback/">
  <channel>
    <title>Title</title>
    <link>http://test.com/project/retro.rss</link>
    <description>Description</description>
    <item>
      <title>Changeset </title>
      <link>http://test.host/projects/retro/changesets/1</link>
      <pubDate>Thu, 01 Jan 2009 00:00:00 +0000</pubDate>
    </item>
  </channel>
</rss>',
          :content_type => 'application/rss+xml'        
        )        
        do_call
      end      

    end

  
  end 
end
