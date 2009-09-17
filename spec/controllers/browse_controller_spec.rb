require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BrowseController do
  it_should_behave_like EveryProjectAreaController
  before do
    @repository = mock_model(Repository::Subversion, :latest_revision => '123')
    @node = mock_model Repository::Subversion::Node, 
      :selected_revision => '120',
      :mime_type => MIME::Types['application/x-ruby'].first,
      :dir? => false, 
      :content_type => :text, 
      :size => 40,
      :date => 2.months.ago,
      :content => 'Some fake file content',
      :path => 'lib/file.rb',
      :name => 'file.rb'
    @repository.stub!(:node).and_return(@node)
    @project = permit_access_with_current_project! :repository => @repository, :absolutize_path => '', :relativize_path => ''
    @proxy = @project.stub_association! :changesets,
      :find_by_revision => mock_model(Changeset)
  end
  

  describe "fetching nodes" do

    def do_get(options = {})
      get :index, options.reverse_merge(:project_id => 'one')      
    end

    it "should find the project\'s repository" do        
      @project.should_receive(:repository).and_return(@repository)
      do_get
    end

    it "should retrieve a node from the repository for the given path" do
      @project.should_receive(:absolutize_path).with('app/models').and_return('project/app/models')
      @repository.should_receive(:node).with('project/app/models', '123').and_return(@node)
      do_get :path => ['app', 'models']
    end

    it "should use the revision parameter if one is passed" do
      @project.should_receive(:absolutize_path).with('app/models').and_return('project/app/models')
      @repository.should_receive(:node).with('project/app/models', '100').and_return(@node)
      do_get :rev => '100', :path => ['app', 'models']
    end

    it "should try to find the changeset fo the node" do
      @proxy.should_receive(:find_by_revision).with('120', :include => [:user]).and_return(nil)
      do_get
    end

    it "should check freshness" do
      @node.should_receive(:date).and_return(2.months.ago)
      do_get
    end

    describe 'error handling' do
      
      describe 'if revision does not exist' do
        it 'should redirect to the latest revision' do
          @repository.should_receive(:node).and_raise(Repository::RevisionNotFound)
          do_get :path => ['app', 'models'], :rev => '2000'
          response.should be_redirect
          response.should redirect_to(project_browse_path(@project, ['app', 'models']))
        end
      end

      describe 'if revision is invalid' do
        it 'should redirect to the latest revision' do
          @repository.should_receive(:node).and_raise(Repository::InvalidRevision)
          do_get :path => ['app', 'models'], :rev => '2000'
          response.should be_redirect
          response.should redirect_to(project_browse_path(@project, ['app', 'models']))
        end
      end

      describe 'if the path does not exist for the selected revision' do
        it 'should redirect to the latest revision' do
          @repository.should_receive(:node).and_raise(Repository::Abstract::Node::InvalidPathForRevision)
          do_get :path => ['app', 'models'], :rev => '2000'
          response.should be_redirect
          response.should redirect_to(project_browse_path(@project, ['app', 'models']))
        end
      end
      
      describe 'if path is invalid' do
        
        describe 'if the selected path IS NOT the root path' do
          
          it 'should redirect to root path and latest revision' do
            @project.stub!(:relativize_path).and_return('app/models')
            @repository.should_receive(:node).and_raise(Repository::Abstract::Node::InvalidPath)
            do_get :path => ['app', 'models'], :rev => '2000'
            response.should redirect_to(project_browse_path(@project, nil))
          end
          
        end

        describe 'if the selected path IS the root path' do
          
          it 'should render repositor unavailable screen' do
            @project.stub!(:relativize_path).and_return('')
            @repository.should_receive(:node).and_raise(Repository::Abstract::Node::InvalidPath)
            do_get :path => ['trunk'], :rev => '2000'
            response.should be_success
            response.should render_template(:repository_unavailable)
          end
          
        end

      end
      
    end    
  end

  describe "handling GET /index" do

    def do_get(options = {})
      get :index, options.reverse_merge(:project_id => 'one')
    end

    describe 'if the node is a directory' do
      before do
        @node.stub!(:dir?).and_return(true)
      end

      def do_get
        super(:path => ['path'])        
      end
      
      it_should_successfully_render_template('index')
    end
    
    describe 'if the node is a non-binary (textual) file' do
      before do
        @node.stub!(:content_type).and_return(:text)
      end
      
      def do_get(options = {})
        super options.reverse_merge(:path => ['file.rb'])
      end

      it 'should identify textual files' do
        @node.should_receive(:content_type).and_return(:text)
        do_get
        response.should be_success
        response.should render_template(:show_file)
      end     

      it 'should identify non-binary files and render the file contents' do
        @node.should_receive(:content_type).and_return(:unknown)
        do_get
        response.should be_success
        response.should render_template(:show_file)
      end

      it 'should ignore invalid format parameters and render the file contents as HTML' do
        @node.should_receive(:content_type).and_return(:unknown)
        do_get :format => 'invalid'
        response.should be_success
        response.should render_template(:show_file)
      end

      it 'should ignore empty format parameters and render the file contents as HTML' do
        @node.should_receive(:content_type).and_return(:unknown)
        do_get :format => ''
        response.should be_success
        response.should render_template(:show_file)
      end

      describe 'if the size is above 512kB' do
        before do
          @node.stub!(:size).and_return(1.megabyte)
          do_get
        end

        it 'should send the file as plain text' do
          response.should be_success
          response.content_type.should == 'text/plain'
          response.headers['Content-Disposition'].should == 'inline'
        end
      end

      describe 'if format parameter \'text\' is passed' do
        before do
          do_get :format => 'text'
        end

        it 'should send the file as plain text' do
          response.should be_success
          response.content_type.should == 'text/plain'
          response.headers['Content-Disposition'].should == 'inline'
        end
      end

      describe 'if format parameter \'raw\' is passed' do
        it 'should send the file with its native content type & disposition' do
          @node.should_receive(:mime_type).and_return(MIME::Types['application/x-ruby'].first)
          @node.should_receive(:disposition).and_return('inline')
          do_get :format => 'raw'
          response.should be_success
          response.content_type.should == 'application/ruby'
          response.headers['Content-Disposition'].should == 'inline'
        end
      end
    end

    describe 'if the node is an image file' do
      before do
        @node.stub!(:content_type).and_return(:image)
      end
      
      def do_get(options = {})
        get :index, options.reverse_merge(:path => ['file.gif'], :project_id => 'one')
      end

      it 'should identify image files' do
        @node.should_receive(:content_type).and_return(:image)
        do_get
        response.should be_success
        response.should render_template(:show_image)
      end     

      describe 'if format parameter \'raw\' is passed' do
        it 'should send the file with its native content type & disposition' do
          @node.should_receive(:mime_type).and_return(MIME::Types['image/gif'].first)
          @node.should_receive(:disposition).and_return('inline')
          do_get :format => 'raw'
          response.should be_success
          response.content_type.should == 'image/gif'
          response.headers['Content-Disposition'].should == 'inline'
        end
      end
    end

    describe 'if the node is a binary file' do
      before do
        @node.stub!(:content_type).and_return(:binary)
      end
      
      def do_get(options = {})
        get :index, options.reverse_merge(:path => ['file.ogg'], :project_id => 'one')
      end

      it 'should identify binary files' do
        @node.should_receive(:content_type).and_return(:binary)
        do_get
        response.should be_success
        response.should render_template(:show_binary)
      end     

      describe 'if format parameter \'raw\' is passed' do
        it 'should send the file with its native content type & disposition' do
          @node.should_receive(:mime_type).and_return(MIME::Types['application/ogg'].first)
          @node.should_receive(:disposition).and_return('attachment')
          do_get :format => 'raw'
          response.should be_success
          response.content_type.should == 'application/ogg'
          response.headers['Content-Disposition'].should == 'attachment'
        end
      end
    end
    
  end

  describe "handling GET /download" do
    
    describe 'if node is a directory' do
      before do
        @node.stub!(:dir?).and_return(true)
      end
      
      it 'should redirect to browse (keeping path and revision)' do
        get :download, :path => ['path'], :rev => '1234', :project_id => 'one'
        response.should be_redirect
        response.should redirect_to(project_browse_path(@project, ['path'], :rev => '1234'))
      end            
    end

    describe 'if node is a file' do
      before do
        @node.stub!(:dir?).and_return(false)
      end
      
      it 'should send the file with its native content type and disposition' do
        @node.should_receive(:mime_type).and_return(MIME::Types['application/ogg'].first)
        @node.should_receive(:disposition).and_return('attachment')
        get :download, :path => ['file.ogg'], :project_id => 'one'
        response.should be_success
        response.content_type.should == 'application/ogg'
        response.headers['Content-Disposition'].should == 'attachment'
      end            
    end
    
  end


  describe "handling GET /revisions" do
    before do
      @changesets = [mock_model(Changeset), mock_model(Changeset)]
      @proxy.stub!(:paginate).and_return(@changesets)
      @node.stub!(:dir?).and_return(true)
      @node.stub!(:path).and_return('path/')
    end    
  
    def do_get(options = {})
      get :revisions, options.reverse_merge(:path => ['path'], :project_id => 'one')
    end
  
    it 'should find all matching changesets for the selected node' do
      @proxy.should_receive(:paginate).with(
        :include => [:changes],
        :page => nil,
        :conditions => ['changes.path LIKE ? AND changes.name != ?', 'path/%', 'D'],
        :order => 'changesets.created_at DESC',
        :per_page => 25        
      ).and_return(@changesets)
      do_get
    end

    it 'should find assign changesets' do
      do_get
      assigns[:revisions].should == @changesets
    end

    it_should_successfully_render_template('revisions')
  end


  describe "handling GET /diff" do    
    
    def do_get(options = {})
      get :diff, options.reverse_merge(:path => ['path'], :rev => '123', :compare_with => '110', :project_id => 'one')
    end
    
    describe 'if no compare-with parameter is passed' do
      it 'should redirect to browse (keeping path and revision)' do
        do_get(:compare_with => nil)
        response.code.should == '400'
      end            
    end

    describe 'if node is a directory' do

      before do
        @node.stub!(:dir?).and_return(true)
      end
      
      it 'should redirect to browse (keeping path and revision)' do
        do_get
        response.should be_redirect
        response.should redirect_to(project_browse_path(@project, ['path'], :rev => '123'))
      end            

    end


    describe 'if node is a file' do
      
      before do
        @udiff = '@@@DIFF@@@'
        @node.stub!(:dir?).and_return(false)        
        @repository.stub!(:unified_diff).and_return(@udiff)
      end
      
      it 'should grab the diff' do
        @repository.should_receive(:unified_diff).with('lib/file.rb', '110', '120').and_return(@udiff)
        do_get                
      end            

      it 'should assign the diff' do
        do_get        
        assigns[:unified_diff].should == @udiff
      end            

      it_should_successfully_render_template('diff')

      describe 'if format param is passed as \'plain\'' do
        it 'should send the plain diff inline' do
          do_get(:format => 'plain')
          response.should be_success
          response.content_type.should == 'text/plain'
          response.headers['Content-Disposition'].should == 'inline; filename="file.rb-[110][120].diff"'
        end
      end
      
    end
  end 

  describe 'resolution of named routes' do
    
    before do
      # make a fake request to activate named-routes methods
      get :index, :project_id => 'one'
    end

    it 'should correctly resolve project-browse-path' do
      project_browse_path('name', nil).should == '/projects/name/browse'
      project_browse_path('name', []).should == '/projects/name/browse'
      project_browse_path('name').should == '/projects/name/browse'
      project_browse_path('name', 'file.rb').should == '/projects/name/browse/file.rb'
      project_browse_path('name', nil, :rev => 'AF03').should == '/projects/name/browse?rev=AF03'
    end
  
    it 'should correctly resolve project-revisions-path' do
      project_revisions_path('name', nil).should == '/projects/name/revisions'
      project_revisions_path('name', []).should == '/projects/name/revisions'        
      project_revisions_path('name').should == '/projects/name/revisions'
      project_revisions_path('name', ['main', 'sub', 'file.rb']).should == '/projects/name/revisions/main/sub/file.rb'         
    end
  
    it 'should correctly resolve project-download-path' do
      project_download_path('name', nil).should == '/projects/name/download'
      project_download_path('name', []).should == '/projects/name/download'        
      project_download_path('name').should == '/projects/name/download'
      project_download_path('name', ['main', 'sub', 'file.rb']).should == '/projects/name/download/main/sub/file.rb'         
    end
    
    it 'should correctly resolve project-diff-path' do
      project_diff_path('name', nil).should == '/projects/name/diff'
      project_diff_path('name', []).should == '/projects/name/diff'
      project_diff_path('name').should == '/projects/name/diff'
      project_diff_path('name', ['main', 'sub', 'file.rb']).should == '/projects/name/diff/main/sub/file.rb'         
    end
  
  end

end
