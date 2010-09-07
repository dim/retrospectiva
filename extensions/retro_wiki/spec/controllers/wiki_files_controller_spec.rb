require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiFilesController do
  it_should_behave_like EveryProjectAreaController

  before do
    @project = permit_access_with_current_project! :name => 'Retro', :wiki_title => 'Retro'
    @user = stub_current_user! :permitted? => true, :projects => [@project]
    @files_proxy = @project.stub_association!(:wiki_files)
    @files_proxy.stub!(:count).and_return(5)
    @files_proxy.stub!(:maximum)
  end

  describe 'GET /index' do
    
    before do
      @files = [mock_model(WikiFile), mock_model(WikiFile)]
      @files_proxy.stub!(:paginate).and_return(@files) 
    end
    
    def do_get
      get :index, :project_id => @project.to_param
    end

    it 'should check freshness' do
      @files_proxy.should_receive(:count).with().and_return(5)
      @files_proxy.should_receive(:maximum).with(:created_at)
      do_get
    end
    
    it 'should load the files' do
      @files_proxy.should_receive(:paginate).with(:page => nil, :order => 'wiki_title').and_return(@files) 
      do_get
      assigns[:files].should == @files 
    end
    
    it "should render the template" do
      do_get
      response.should be_success
      response.should render_template(:index)
    end

  end


  describe 'GET /show' do
    
    before do
      @file = mock_model(WikiFile, :readable? => true, :send_arguments => ['path', {}], :created_at => 2.days.ago, :redirect? => false)
      @files_proxy.stub!(:find_by_wiki_title!).and_return(@file)
      controller.stub!(:send_file) 
      controller.stub!(:render) 
    end
    
    def do_get
      get :show, :id => 'My Title', :project_id => @project.to_param
    end
    
    it 'should load the file' do
      @files_proxy.should_receive(:find_by_wiki_title!).with('My Title').and_return(@file)
      do_get
      assigns[:wiki_file].should == @file 
    end

    it 'should check if file is readbale' do
      @file.should_receive(:readable?).and_return(true)
      do_get
    end
    
    it 'should check freshness' do
      @file.should_receive(:created_at)
      do_get
    end

    describe 'if file is not readable' do
      before do
        @file.stub!(:readable?).and_return(false)
      end
      
      it 'should display an error' do
        controller.should_receive(:render).with(:text => 'Unable to download file')
        do_get
      end      
    end

    it "should send the file" do
      controller.should_receive(:send_file).with('path', {}) 
      do_get
    end
        
  end

  describe 'GET /new' do
    
    before do
      @file = mock_model(WikiFile, :new_record? => true)
      @files_proxy.stub!(:new).and_return(@file)
    end
    
    def do_get
      get :new, :project_id => @project.to_param
    end

    it 'should intialize the file' do
      @files_proxy.should_receive(:new).with(nil).and_return(@file)
      do_get
      assigns[:wiki_file].should == @file
    end

    it "should render the template" do
      do_get
      response.should be_success
      response.should render_template(:new)
    end      
    
  end


  describe 'POST /create' do
    
    before do
      @file = mock_model(WikiFile, :new_record? => true, :save => true, :wiki_title= => nil)
      @files_proxy.stub!(:new).and_return(@file)
    end
    
    def do_post
      post :create, :wiki_file => { :file => '[F]', :wiki_title => 'Title' }, :project_id => @project.to_param
    end

    it 'should initalize a new file and assign the title' do
      @files_proxy.should_receive(:new).with('[F]').and_return(@file)
      @file.should_receive(:wiki_title=).with('Title')
      do_post
      assigns[:wiki_file].should == @file
    end
    
    describe 'when successfully saved' do
      
      it 'should redirect to index' do
        @file.should_receive(:save).and_return(true)
        do_post
        response.should redirect_to(project_wiki_files_path(@project))
      end
      
    end

    describe 'when save is NOT successful' do

      it "should render the new screen" do
        @file.should_receive(:save).and_return(false)
        do_post
        response.should be_success
        response.should render_template(:new)
      end      
      
    end
    
  end


  describe 'DELETE /destroy' do
    
    before do
      @file = mock_model(WikiFile, :destroy => true)
      @files_proxy.stub!(:find_by_wiki_title!).and_return(@file)
    end
    
    def do_delete
      delete :destroy, :id => 'Title', :project_id => @project.to_param
    end

    it 'should load the page' do
      @files_proxy.should_receive(:find_by_wiki_title!).with('Title').and_return(@file)
      do_delete
      assigns[:wiki_file].should == @file
    end

    it "should delete the record" do
      @file.should_receive(:destroy).and_return(true)
      do_delete
    end

    it 'should redirect to project\'s home page' do
      do_delete
      response.should redirect_to(project_wiki_files_path(@project))
    end
    
  end

end
