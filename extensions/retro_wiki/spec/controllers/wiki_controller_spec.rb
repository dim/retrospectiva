require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiController do
  it_should_behave_like EveryProjectAreaController

  before do
    @project = permit_access_with_current_project! :name => 'Retro', :wiki_title => 'Retro'
    @user = stub_current_user! :permitted? => true, :projects => [@project]
    @pages_proxy = @project.stub_association!(:wiki_pages)
  end

  describe 'GET /index' do
    
    before do
      @pages = [mock_model(WikiPage), mock_model(WikiPage)]
      @pages_proxy.stub!(:paginate).and_return(@pages) 
      @pages_proxy.stub!(:count).and_return(1)
      @pages_proxy.stub!(:maximum)
    end
    
    def do_get(options = {})
      get :index, options.merge(:project_id => @project.to_param)
    end

    it 'should check feshness' do
      @pages_proxy.should_receive(:count).and_return(1)
      @pages_proxy.should_receive(:maximum).with(:updated_at)
      do_get
    end
    
    it 'should load the pages' do
      @pages_proxy.should_receive(:paginate).with(:page => nil, :per_page => nil, :order => 'wiki_pages.title', :total_entries => nil).and_return(@pages) 
      do_get
      assigns[:pages].should == @pages 
    end

    it 'should order the pages by last update if requested' do
      @pages_proxy.should_receive(:paginate).with(:page => nil, :per_page => nil, :order => 'wiki_pages.updated_at DESC', :total_entries => nil).and_return(@pages) 
      do_get :order => 'recent'
      assigns[:pages].should == @pages 
    end
    
    it "should render the template" do
      do_get
      response.should be_success
      response.should render_template(:index)
    end

  end


  describe 'GET /show' do
    
    before do
      @version = mock_model(WikiVersion, :updated_at => 14.days.ago)
      @page = mock_model(WikiPage, :versions => [@version], :updated_at => 10.days.ago)
      @page.stub!(:find_version).and_return(nil)
      @pages_proxy.stub!(:find_by_title).and_return(@page)
    end
    
    def do_get(options = {})
      get :show, options.merge(:id => 'My Title', :project_id => @project.to_param)
    end
    
    it 'should load the page' do
      @page.should_receive(:find_version).with(nil).and_return(nil)
      @pages_proxy.should_receive(:find_by_title).with('My Title', :include => [:versions]).and_return(@page)
      do_get
      assigns[:wiki_page].should == @page 
    end

    it 'should check freshness' do
      @page.should_receive(:updated_at).and_return(10.days.ago)
      do_get
    end

    describe 'if a version parameter was given' do
      
      it 'should load the version' do        
        @page.should_receive(:find_version).with('1').and_return(@version)
        do_get(:version => '1')
        assigns[:wiki_page].should == @version 
      end

    end

    describe 'if a page (or version) was found ' do

      it "should render the template" do
        do_get
        response.should be_success
        response.should render_template(:show)
      end
      
    end
        
    describe 'if page cannot be found' do
      
      describe 'and user has the permission to update pages' do
        
        it 'should redirect to edit' do
          @pages_proxy.should_receive(:find_by_title).and_return(nil)
          @user.should_receive(:permitted?).with(:wiki_pages, :update).and_return(true)
          do_get
          response.should redirect_to(edit_project_wiki_page_path(@project, 'My Title'))
        end      
        
      end

      describe 'and user doesn\'t have the permission to update pages' do
        
        it 'should redirect to index' do
          @pages_proxy.should_receive(:find_by_title).and_return(nil)
          @user.should_receive(:permitted?).with(:wiki_pages, :update).and_return(false)
          do_get
          response.should redirect_to(project_wiki_pages_path(@project))
        end      
        
      end
    end
  end

  describe 'GET /edit' do
    
    before do
      @version = mock_model(WikiVersion, :content => 'Old Content')
      @page = mock_model(WikiPage, :versions => [@version], :author= => nil)
      @page.stub!(:find_version).and_return(nil)
      @pages_proxy.stub!(:find_or_build).and_return(@page)
      controller.stub!(:cached_user_attribute)
    end
    
    def do_get(options = {})
      get :edit, options.merge(:id => 'My Title', :project_id => @project.to_param)
    end

    it 'should load the page' do
      @pages_proxy.should_receive(:find_or_build).with('My Title').and_return(@page)
      @page.should_receive(:find_version).and_return(nil)
      do_get
      assigns[:wiki_page].should == @page
    end

    describe 'if a version parameter was given' do
      
      it 'should assign(rollback) its content to the page' do
        @page.should_receive(:find_version).and_return(@version)
        @page.should_receive(:content=).with('Old Content')
        do_get(:version => '1')
      end

    end

    it 'should try to assign an author based on cookie information' do
      @page.should_receive(:author=).with('Name')
      controller.should_receive(:cached_user_attribute).and_return('Name')
      do_get
    end

    it "should render the template" do
      do_get
      response.should be_success
      response.should render_template(:edit)
    end      
    
  end


  describe 'PUT /update' do
    
    before do
      @page = mock_model(WikiPage, :update_attributes => true, :author => 'Me', :number => 1)
      @pages_proxy.stub!(:find_or_build).and_return(@page)
      controller.stub!(:cache_user_attributes!)
    end
    
    def do_put
      put :update, :id => 'My Title', :wiki_page => {}, :project_id => @project.to_param
    end

    it 'should load the page' do
      @pages_proxy.should_receive(:find_or_build).with('My Title').and_return(@page)
      do_put
      assigns[:wiki_page].should == @page
    end
    
    describe 'when update is successful' do
      
      it 'should redirect to show' do
        @page.should_receive(:update_attributes).with({}).and_return(true)
        do_put
        response.should redirect_to(project_wiki_page_path(@project, @page))
      end
      
      it 'should cache the author setting' do
        controller.should_receive(:cache_user_attributes!).with(:name => 'Me')
        do_put
      end      
      
    end

    describe 'when update is NOT successful' do

      before do
        @page.stub!(:update_attributes).and_return(false)
      end

      it "should render the edit screen" do
        do_put
        response.should be_success
        response.should render_template(:edit)
      end      
      
    end
    
  end


  describe 'GET /rename' do
    
    before do
      @page = mock_model(WikiPage)
      @pages_proxy.stub!(:find_by_title!).and_return(@page)
    end
    
    def do_get
      get :rename, :id => 'My Title', :project_id => @project.to_param
    end

    it 'should load the page' do
      @pages_proxy.should_receive(:find_by_title!).with('My Title').and_return(@page)
      do_get
      assigns[:wiki_page].should == @page
    end

    it "should render the template" do
      do_get
      response.should be_success
      response.should render_template(:rename)
    end
    
  end


  describe 'PUT /update_title' do
    
    before do
      @page = mock_model(WikiPage, :title= => nil, :save => true)
      @pages_proxy.stub!(:find_by_title!).and_return(@page)
    end
    
    def do_put
      put :update_title, :id => 'My Title', :title => 'New Title', :project_id => @project.to_param
    end

    it 'should load the page' do
      @pages_proxy.should_receive(:find_by_title!).with('My Title').and_return(@page)
      do_put
      assigns[:wiki_page].should == @page
    end

    it "should assign the new title" do
      @page.should_receive(:title=).with('New Title')
      do_put
    end

    describe 'when update is successful' do
      
      it 'should redirect to show' do
        @page.should_receive(:save).and_return(true)
        do_put
        response.should redirect_to(project_wiki_page_path(@project, @page))
      end
      
    end

    describe 'when update is NOT successful' do

      it "should render the rename screen" do
        @page.should_receive(:save).and_return(false)
        do_put
        response.should be_success
        response.should render_template(:rename)
      end      
      
    end    
    
  end


  describe 'DELETE /destroy' do
    
    before do
      @page = mock_model(WikiPage, :destroy => true)
      @pages_proxy.stub!(:find_by_title!).and_return(@page)
    end
    
    def do_delete
      delete :destroy, :id => 'My Title', :project_id => @project.to_param
    end

    it 'should load the page' do
      @pages_proxy.should_receive(:find_by_title!).with('My Title').and_return(@page)
      do_delete
      assigns[:wiki_page].should == @page
    end

    it "should delete the record" do
      @page.should_receive(:destroy).and_return(true)
      do_delete
    end

    it 'should redirect to project\'s home page' do
      do_delete
      response.should redirect_to(project_wiki_page_path(@project, 'Retro'))
    end
    
  end


end
