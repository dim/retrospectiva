require File.dirname(__FILE__) + '/../../spec_helper'

describe "/browse/show_binary.html.erb" do
  include Spec::RepositoryInclude

  before do 
    @project = stub_current_project!    
    @user = stub_current_user! :permitted? => false
    assigns[:node] = @node = mock_binary_node
    template.stub!(:browseable_path).and_return('<h2>PATH_BREADCRUMBS</h2>')
  end
    
  def do_render
    render '/browse/show_binary'
  end
  
  it 'should display the path navigation breadcrumbs' do
    template.should_receive(:browseable_path).and_return('<h2>PATH_BREADCRUMBS</h2>')
    do_render
    response.should have_tag('div.repository-browser h2', 'PATH_BREADCRUMBS')
  end

  it 'should render the header' do
    template.should_receive(:render).with(:partial => 'show_header', :locals => {:formats => [:raw]})
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
end