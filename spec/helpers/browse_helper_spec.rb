require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BrowseHelper do
  fixtures :projects

  before do 
    @project = projects(:retro)
    Project.stub!(:current).and_return(@project)
    @user = stub_current_user! :has_access? => true
    @path = ['folder', 'file.rb']
    @params = { :rev => 'R123', :path => @path }
    helper.extend ApplicationHelper
    helper.extend ProjectAreaHelper
    helper.stub!(:params).and_return(@params)
  end


  describe 'rendering browsable path' do

    it 'should create click-able path tokens with root-path prefix, wrapped in a h2 tag' do      
      helper.browseable_path.should == 
        "<h2 class=\"browseable-path\">" +
          "<a href=\"/projects/retrospectiva/browse?rev=R123\" title=\"Browse root [R123]\">root</a>"+
          "/"+
          "<a href=\"/projects/retrospectiva/browse/folder?rev=R123\" title=\"Browse folder [R123]\">folder</a>"+
          "/"+
          "<a href=\"/projects/retrospectiva/browse/folder/file.rb?rev=R123\" title=\"Browse folder/file.rb [R123]\">file.rb</a>"+
        "</h2>"
    end

    it 'should allow to make the last iten non-clickable' do      
      helper.browseable_path(false).should == 
        "<h2 class=\"browseable-path\">" +
          "<a href=\"/projects/retrospectiva/browse?rev=R123\" title=\"Browse root [R123]\">root</a>"+
          "/"+
          "<a href=\"/projects/retrospectiva/browse/folder?rev=R123\" title=\"Browse folder [R123]\">folder</a>"+
          "/"+
          "file.rb"+
        "</h2>"
    end    

  end


  describe 'formatting SCM properties' do

    it 'should sort by key, escape keys/values and render them correctly' do      
      helper.format_properties('B & C' => 'none', 'A' => 'X & Y').should == 
        "<em class=\"loud\">A</em>: X &amp; Y, <em class=\"loud\">B &amp; C</em>: none"
    end

  end


  describe 'formatting code' do

    before do
      @content = "# Comment\ndef name\nend"
      @node = mock_model Repository::Git::Node, :content => @content, :path => 'folder/file.rb'
      helper.stub!(:link_to_code_line).and_return('LINK')
      helper.stub!(:content_tag).and_return('TABLE')
    end
    
    it 'should highlight syntax' do      
      helper.should_receive(:syntax_highlight).with(@node).and_return(@content)
      helper.format_code_with_line_numbers(@node).should == 'TABLE'
    end

    it 'should links create links to each line' do      
      helper.should_receive(:link_to_code_line).exactly(3).times.and_return('LINK')
      helper.format_code_with_line_numbers(@node).should == 'TABLE'
    end

    it 'should return a HTML table' do      
      helper.should_receive(:content_tag).once.and_return('TABLE')
      helper.format_code_with_line_numbers(@node).should == 'TABLE'
    end

  end


  describe 'links to diff code' do

    before do
      @node = mock_model(Repository::Abstract::Node, :dir? => false, :revision => 'R10', :binary? => false)
    end

    def do_call
      helper.link_to_diff('LABEL', @node, ['folder', 'info.txt'], 'R5')
    end
    
    it 'should return a space if the node is a directory' do
      @node.should_receive(:dir?).and_return(true)
      do_call.should == '&nbsp;'
    end

    it 'should return a space if the node is binary' do
      @node.should_receive(:binary?).and_return(true)
      do_call.should == '&nbsp;'
    end

    it "should return 'Current' if the node has the same revision" do
      @node.should_receive(:revision).and_return('R5')
      do_call.should == '<em>Current</em>'
    end

    it 'should render a link to DIFF' do
      helper.should_receive(:project_diff_path).with(@project, ['folder', 'info.txt'], 
        :rev => 'R10', 
        :compare_with => 'R5'
      ).and_return('URL')
      helper.should_receive(:link_to).with('LABEL', 'URL', :title=>"Compare [R10] with [R5]").and_return('LINK')
      do_call.should == 'LINK'
    end    

  end


  describe 'short-cut link to revisions' do

    it 'should return a link to revisions overview' do
      helper.should_receive(:project_revisions_path).with(@project, @path, 
        :rev => @params[:rev]
      ).and_return('URL')
      helper.should_receive(:link_to).with('Revisions', 'URL').and_return('LINK')
      helper.link_to_revisions.should == 'LINK'
    end    

  end


  describe 'node-download links' do
  
    before do
      helper.stub!(:project_download_path).and_return('RAW_URL')
      helper.stub!(:project_browse_path).and_return('TEXT_URL')
      helper.stub!(:link_to).and_return('LINK')
      helper.stub!(:link_to).with('Raw', 'RAW_URL').and_return('RAW_LINK')
      helper.stub!(:link_to).with('Text', 'TEXT_URL').and_return('TEXT_LINK')
    end

    def do_call(*formats)
      formats = [:raw, :text, :other] if formats.blank?
      helper.node_download_links(*formats)
    end
    
    it 'should keep the current path and revision in the link' do
      helper.should_receive(:project_download_path).with(@project, @path, 
        :rev => @params[:rev]
      ).and_return('RAW_URL')
      helper.should_receive(:project_browse_path).with(@project, @path, 
        :rev => @params[:rev],
        :format => 'text'
      ).and_return('TEXT_URL')      
      do_call.should == 'RAW_LINK | TEXT_LINK'
    end
        
    it 'should return ordered links to download' do
      do_call(:text, :raw).should == 'TEXT_LINK | RAW_LINK'
    end
    
    it 'should ignore unknown values' do
      do_call(:raw, 'raw', :text, :other).should == 'RAW_LINK | TEXT_LINK'            
    end

    it 'should remove duplicates' do
      do_call(:raw, :raw, :text).should == 'RAW_LINK | TEXT_LINK'            
    end    

  end

  
  describe 'linking code lines' do

    before do
      helper.stub!(:project_browse_path).and_return('URL')
      helper.stub!(:link_to).and_return('LINK')
      assigns[:node] = @node = mock_model(Repository::Abstract::Node, :selected_revision => 'R100')
    end
    
    it 'should create a link with anchor' do
      helper.should_receive(:project_browse_path).with(@project, @path, 
        :rev => 'R100',
        :anchor => 'ln3'
      ).and_return('URL')
      helper.send(:link_to_code_line, 3).should == 'LINK'
    end

    it 'should add an id, a title and a class to the link' do
      helper.should_receive(:link_to).with('3', 'URL',
        :id => 'ln3',
        :class => 'block',
        :title => 'Line 3'
      ).and_return('LINK')
      helper.send(:link_to_code_line, 3).should == 'LINK'
    end

  end


  describe 'highlighting syntax' do        

    before do
      @content = "def method_name\n  p 'Hi, it\'s me'\nend"
      @node = mock_model Repository::Git::Node, :content => @content, :path => 'folder/file.rb'
    end

    def do_call
      helper.send(:syntax_highlight, @node)
    end
    
    describe 'the workflow' do

      before do
        @lib = mock_model(CodeRay, :html => 'CODE')
        CodeRay.stub!(:scan).and_return(@lib)
      end
      
      it 'should call vendor highlighter library with the right params' do
        CodeRay.should_receive(:scan).with(@content, :ruby).and_return(@lib)
        do_call.should == 'CODE'
      end    
  
      it 'should return results as formatted HTML' do
        @lib.should_receive(:html).and_return('CODE')
        do_call.should == 'CODE'
      end
    end
    
    describe 'in real world' do

      it 'should correctly highlight the code' do
        do_call.should == %Q(
<span class=\"r\">def</span> <span class=\"fu\">method_name</span>
  p <span class=\"s\"><span class=\"dl\">'</span><span class=\"k\">Hi, it</span><span class=\"dl\">'</span></span>s me<span class=\"s\"><span class=\"dl\">'</span><span class=\"k\">
end</span></span>
).strip

      end      
    end
  end
end
