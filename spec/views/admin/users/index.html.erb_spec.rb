require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/index.html.erb" do
  
  before(:each) do
    stub_current_user! :admin? => true
    @user = stub_model(User, :groups => [stub_model(Group)])
    user_2 = stub_model(User)

    assigns[:users] = [@user, user_2].paginate(:per_page => 1)
  end

  def do_render
    render "/admin/users/index.html.erb", :helper => 'admin_area'
  end
  
  it "should render list of users" do
    do_render
    response.should have_tag('table.record-list', 1)
  end

  it "should show link to create new user" do
    do_render
    response.should have_tag('a[href=?]', '/admin/users/new', 'Create a new user')
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

  it "should render the users partial" do
    template.should_receive(:render).with(:partial => 'user', :collection => assigns[:users])
    do_render
  end

end

