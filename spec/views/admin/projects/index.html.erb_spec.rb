require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/projects/index.html.erb" do
  
  before(:each) do
    stub_current_user! :admin? => true
    @project = stub_model(Project, :name => 'P1', :short_name => 'any')
    project_2 = stub_model(Project)

    assigns[:projects] = [@project, project_2].paginate(:per_page => 1)
  end

  def do_render
    render "/admin/projects/index.html.erb", :helper => 'admin_area'
  end
  
  it "should render list of projects" do
    do_render
    response.should have_tag('table.record-list', 1)
  end

  it "should show link to create new project" do
    do_render
    response.should have_tag('a[href=?]', '/admin/projects/new', 'Create a new project')
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

  it "should render the projects partial" do
    template.should_receive(:render).with(:partial => 'project', :collection => assigns[:projects])
    do_render
  end

end

