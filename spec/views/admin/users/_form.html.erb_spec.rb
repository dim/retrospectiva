require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/users/_form.html.erb" do
  
  before(:each) do
    stub_current_user! :admin? => true
    assigns[:user] = @user = stub_model(User)
    @group = stub_model(Group, :name => 'G1')
    assigns[:groups] = [@group]
  end

  def do_render
    render "/admin/users/edit.html.erb", :helper => 'admin_area'
  end
    
  it "should render the form fields" do
    RetroCM[:general][:user_management].should_receive(:[]).twice.with(:activation).and_return('auto')
    do_render
    response.should have_tag('form') do
      with_text_field_for(:username)
      with_text_field_for(:email)
      with_text_field_for(:plain_password)
      with_text_field_for(:plain_password_confirmation)
      with_checkbox_for(:admin)
      with_checkbox_for(:active)
    end
  end

  it "should render the group selection" do
    do_render
    response.should have_tag('form fieldset') do
      with_checkbox_for("group_ids_#{@group.id}")
    end
  end

end

