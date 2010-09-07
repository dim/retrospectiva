require File.dirname(__FILE__) + '/../../spec_helper'

describe "/browse/diff.html.erb" do
  include Spec::RepositoryInclude
  
  before do 
    @repository = stub_model(Repository::Subversion)
    @project = stub_current_project! :repository => @repository
    @user = stub_current_user! :permitted? => false
    assigns[:node] = @node = mock_text_node
    template.stub!(:browseable_path).and_return('<h2>PATH_BREADCRUMBS</h2>')
    template.stub!(:link_to_browse).and_return('<a>BROWSE_LINK</a>')
    template.stub!(:link_to_revisions).and_return('<a>REVISIONS_LINK</a>')
    template.params[:path] = ['folder', 'file.txt']
    assigns[:unified_diff] = 'DIFF_CONTENT'
  end
    
  def do_render
    render '/browse/diff'
  end
  
  it 'should display the path navigation breadcrumbs' do
    template.should_receive(:browseable_path).and_return('<h2>PATH_BREADCRUMBS</h2>')
    do_render
    response.should have_tag('div.repository-browser h2', 'PATH_BREADCRUMBS')
  end

  it 'should display a link to browse in the content-header' do
    template.should_receive(:link_to_browse).with('Browse', template.params[:path], nil).and_return('<a>BROWSE_LINK</a>')
    do_render
    response.should have_tag('div.content-header a', 'BROWSE_LINK')
  end
  
  it 'should display a link to revisions in the content-header' do
    template.should_receive(:link_to_revisions).and_return('<a>REVISIONS_LINK</a>')
    do_render
    response.should have_tag('div.content-header a', 'REVISIONS_LINK')
  end

  it 'should display a link to diff-download in the content-header' do
    do_render
    response.should have_tag('div.content-header a', 'Download')
  end

  it 'should show the top-link' do
    template.should_receive(:top_link).and_return('<a>TOP!</a>')
    do_render
    response.should have_tag('a', 'TOP!')
  end

  it 'should display the diff' do
    template.should_receive(:format_diff).with('DIFF_CONTENT', 'folder/file.txt').
      and_return('<div class="diff">FORMATTED_DIFF</div>')
    do_render
    response.should have_tag('div.diff', 'FORMATTED_DIFF')
  end

  describe 'if diff is not available' do

    before do
      assigns[:unified_diff] = ''
    end

    it 'should NOT display the diff' do
      template.should_not_receive(:format_diff)
      do_render
    end

    it 'should display an error message' do
      do_render      
      response.should have_tag('h1', 'Invalid or empty DIFF')      
    end

  end  
end