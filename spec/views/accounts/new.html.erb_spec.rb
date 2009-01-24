require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/new.html.erb" do
  
  before(:each) do
    assigns[:user] = stub_model(User)
  end

  def do_render
    render "/accounts/new"
  end
    
  it "should render the form" do
    do_render
    response.should have_form_posting_to(account_path) do
      with_submit_button
    end
  end
  
end

