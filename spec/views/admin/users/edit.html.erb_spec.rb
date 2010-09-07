require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/edit.html.erb" do
  
  before(:each) do
    stub_current_user! :admin? => true
    assigns[:user] = @user = stub_model(User, :groups => [stub_model(Group)])
    assigns[:groups] = [stub_model(Group, :name => 'G1')]
  end

  def do_render
    render "/admin/users/edit.html.erb", :helper => 'admin_area'
  end
    
  it "should render the form" do
    do_render
    response.should have_form_puting_to(admin_user_path(@user)) do
      with_submit_button
      with_link_to(admin_users_path)
    end
  end
  
  it "should render the page header" do
    template.should_receive(:render).with(:partial => 'header')
    do_render
  end

end

