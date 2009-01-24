require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/edit.html.erb" do
  
  before(:each) do
    mock_current_user! :admin? => true
    assigns[:user] = @user = mock_model(User,
      :email => 'me@home.com', :username => 'me', :name => 'Full Name', :scm_name => 'me',      
      :plain_password => nil, :plain_password_confirmation => nil,
      :active => true, :admin => false, :public? => false, :new_record? => false,
      :current? => false, :last_admin? => false, :time_zone => 'London')
    assigns[:groups] = [mock_model(Group, :name => 'G1')]
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

