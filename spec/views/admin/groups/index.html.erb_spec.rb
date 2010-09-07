require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/groups/index.html.erb" do
  
  before(:each) do
    stub_current_user! :admin? => true
    @group = stub_model(Group, :project_names => %w(P1 P2) )
    group_2 = stub_model(Group)

    assigns[:groups] = [@group, group_2].paginate(:per_page => 1)
  end

  def do_render
    render "/admin/groups/index.html.erb", :helper => 'admin_area'
  end
  
  it "should render list of groups" do
    do_render
    response.should have_tag('table.record-list', 1)
  end

  it "should show link to create new group" do
    do_render
    response.should have_tag('a[href=?]', '/admin/groups/new', 'Create a new group')
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

  it "should render the groups partial" do
    template.should_receive(:render).with(:partial => 'group', :collection => assigns[:groups])
    do_render
  end

end

