require File.dirname(__FILE__) + '/../../spec_helper'

describe "/browse/index.html.erb" do
  include Spec::RepositoryInclude

  before do 
    @project = stub_current_project! :relativize_path => '', :absolutize_path => '' 
    @user = stub_current_user! :permitted? => false, :has_access? => true
    assigns[:node] = @node = mock_text_node
    template.stub!(:browseable_path).and_return('<h2>PATH_BREADCRUMBS</h2>')
    template.stub!(:link_to_revisions).and_return('<a>REVISIONS_LINK</a>')
  end
    
  def do_render
    render '/browse/index', :helper => 'project_area'
  end
  
  it 'should display the path navigation breadcrumbs' do
    template.should_receive(:browseable_path).and_return('<h2>PATH_BREADCRUMBS</h2>')
    do_render
    response.should have_tag('div.repository-browser h2', 'PATH_BREADCRUMBS')
  end

  it 'should display a link to revisions in the content-header' do
    template.should_receive(:link_to_revisions).and_return('<a>REVISIONS_LINK</a>')
    do_render
    response.should have_tag('div.content-header a', 'REVISIONS_LINK')
  end
  
  it 'should render the node information' do
    template.should_receive(:render).with(:partial => 'node_info')
    do_render
  end

  it 'should render a link to the latest revision if available' do
    @node.should_receive(:latest_revision?).and_return(false)
    do_render
    response.should have_tag('div.node-info a', 'Show latest')
  end


  describe 'if node is the root' do

    it 'should show no link to parent directory' do
      do_render
      response.should_not have_tag('a', '..')
    end

  end  


  describe 'if node is not the root' do

    before do
      template.params[:path] = ['folder']
    end

    it 'should show no link to parent directory' do
      template.should_receive(:link_to_browse).with('..', [], nil).and_return('<a>..</a>')
      do_render
      response.should have_tag('a', '..')
    end

  end  


  describe 'if node has sub-nodes' do

    before do
      template.params[:path] = ['folder']
      template.stub!(:link_to_browse).and_return('<a>BROWSE_LINK</a>')
      template.stub!(:link_to_changeset).and_return('<a>CHANGESET_LINK</a>')
            
      @sub_node = mock_text_node :name => 'info.txt',
        :path => 'folder/info.txt',
        :date => 2.months.ago,
        :revision => 'R5',
        :short_revision => 'R5',
        :author => 'me',
        :log => 'M1',
        :size => 40
      @collection = [@sub_node]
      @node.stub!(:sub_nodes).and_return(@collection)
    end
    
    it 'should render the sub-nodes' do
      template.should_receive(:render).with(:partial => 'node', :collection => @collection)
      do_render
    end

    it 'should render one line per-node' do
      do_render
      response.should have_tag('tbody tr', 2) do 
        with_tag('td.node-type-text')
      end
    end
    
    it 'should link the nodes' do
      template.should_receive(:link_to_browse).with("info.txt", "folder/info.txt", nil).and_return('<a>info.txt</a>')
      do_render
      response.should have_tag('tbody tr a', 'info.txt')
    end    

    it 'should show a links to the node\'s changeset' do
      template.should_receive(:link_to_changeset).with('[R5]', 'R5').and_return('<a>[R5]</a>')
      do_render
      response.should have_tag('tbody tr a', '[R5]')
    end    
  end

end