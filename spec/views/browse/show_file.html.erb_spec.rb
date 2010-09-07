require File.dirname(__FILE__) + '/../../spec_helper'

describe "/browse/show_file.html.erb" do
  include Spec::RepositoryInclude

  before do 
    @project = stub_current_project!    
    @user = stub_current_user! :permitted? => false
    assigns[:node] = @node = mock_text_node
    template.stub!(:browseable_path).and_return('<h2>PATH_BREADCRUMBS</h2>')
    template.params[:path] = ['folder', 'file.txt']
  end
    
  def do_render
    render '/browse/show_file'
  end
  
  it 'should display the path navigation breadcrumbs' do
    template.should_receive(:browseable_path).and_return('<h2>PATH_BREADCRUMBS</h2>')
    do_render
    response.should have_tag('div.repository-browser h2', 'PATH_BREADCRUMBS')
  end

  it 'should render the header' do
    template.should_receive(:render).with(:partial => 'show_header', :locals => {:formats => [:raw, :text]})
    do_render
  end

  it 'should render the node information' do
    template.should_receive(:render).with(:partial => 'node_info')
    do_render
  end

  it 'should show the top-link' do
    template.should_receive(:top_link).and_return('<a>TOP!</a>')
    do_render
    response.should have_tag('a', 'TOP!')
  end

  it 'should show a link to download the RAW version' do
    do_render
    response.should have_tag('a', 'Raw')
  end

  it 'should show a link to download the PLAIN version' do
    do_render
    response.should have_tag('a', 'Text')
  end

  it 'should show the code' do
    template.should_receive(:format_code_with_line_numbers).with(@node).and_return('<div class="code">CODE_LINES</div>')
    do_render
    response.should have_tag('div.code', 'CODE_LINES')
  end

  describe 'if the content type is unknown' do
    before do
      @node.stub!(:content_type).and_return(:unknown)
    end

    it 'should show a warning' do
      do_render
      response.should have_tag('div.box h2', 'Unknown File Type')
    end
  end
end