require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/repositories/index.html.erb" do
  
  before(:each) do
    stub_current_user! :admin? => true
    @repository = mock_model(Repository::Subversion, :name => 'R1', :kind => 'Subversion')
    repository_2 = mock_model(Repository::Subversion)

    assigns[:repositories] = [@repository, repository_2].paginate(:per_page => 1)
  end

  def do_render
    render "/admin/repositories/index.html.erb", :helper => 'admin_area'
  end
  
  it "should render list of repositories" do
    do_render
    response.should have_tag('table.record-list', 1)
  end

  it "should show link to create new repository" do
    do_render
    response.should have_tag('a[href=?]', '/admin/repositories/new', 'Create a new repository')
  end            

  it "should show link to administration dashboard" do
    do_render
    response.should have_tag('a[href=?]', '/admin', 'Dashboard')
  end            

  it "should show pagination" do
    template.should_receive(:will_paginate).twice.and_return('PAGINATION')
    do_render
    response.should have_tag('thead tr td', 'PAGINATION')
    response.should have_tag('tfoot tr th', 'PAGINATION')
  end

  it "should show per-page selection" do
    template.should_receive(:will_paginate_per_page).and_return('PER_PAGE')
    do_render
    response.should have_tag('tfoot tr th', 'PER_PAGE')
  end

  it "should render the repositories partial" do
    template.should_receive(:render).with(:partial => 'repository', :collection => assigns[:repositories])
    do_render
  end

end

