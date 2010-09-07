require File.dirname(__FILE__) + '/../../spec_helper'

describe "/browse/revisions.html.erb" do
  include Spec::RepositoryInclude
  
  before do 
    @project = stub_current_project! :relativize_path => '', :absolutize_path => ''   
    @user = stub_current_user! :permitted? => false, :has_access? => true
    assigns[:node] = @node = mock_text_node
    assigns[:revisions] = @revisions = [
      mock_model(Changeset,
        :revision => 'R10',
        :short_revision => 'R10',
        :created_at => 1.month.ago,
        :author => 'me',
        :log => 'LOG1'
      ),
      mock_model(Changeset)
    ].paginate(:per_page => 1)
    template.stub!(:browseable_path).and_return('<h2>PATH_BREADCRUMBS</h2>')
  end
    
  def do_render
    render '/browse/revisions', :helper => 'project_area'
  end
  
  it 'should display the path navigation breadcrumbs' do
    template.should_receive(:browseable_path).and_return('<h2>PATH_BREADCRUMBS</h2>')
    do_render
    response.should have_tag('div.repository-browser h2', 'PATH_BREADCRUMBS')
  end

  it 'should display a link to browse in the content-header' do
    do_render
    response.should have_tag('div.content-header a[href=?]', "/projects/#{@project.id}/browse", 'Browse')
    response.should have_tag('div.content-header a[title=?]', "Browse root")
  end
  
  it 'should render the node information' do
    template.should_receive(:render).with(:partial => 'node_info')
    do_render
  end

  it 'should render the pagination' do
    template.should_receive(:will_paginate).and_return('<div>PAGINATION</div>')
    do_render
    response.should have_tag('table thead tr') do
      with_tag 'div', 'PAGINATION'
    end
  end

  it 'should render revision rows' do
    template.should_receive(:render).with(:partial => 'revision', :collection => @revisions)
    do_render
  end

  it 'should show the top-link' do
    template.should_receive(:top_link).and_return('<a>TOP!</a>')
    do_render
    response.should have_tag('a', 'TOP!')
  end

  it 'should show links to diffs' do
    template.should_receive(:link_to_diff).and_return('<a>DIFF_LINK</a>')
    do_render
    response.should have_tag('a', 'DIFF_LINK', 1)
  end

  describe 'if user has the permission to view changesets' do
    
    it 'should show links to changesets' do
      @user.should_receive(:permitted?).with(:changesets, :view).twice.and_return(true)
      template.should_receive(:link_to_changeset).and_return('<a>CHANGESET_LINK</a>')
      do_render
      response.should have_tag('a', 'CHANGESET_LINK', 1)
    end

  end  
end