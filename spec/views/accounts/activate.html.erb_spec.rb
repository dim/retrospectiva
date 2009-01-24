require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/accounts/activate.html.erb" do
  
  before(:each) do
  end

  def do_render
    render "/accounts/activate"
  end
    
  it "should render the form" do
    do_render
    response.should have_form_posting_to(account_activate_path) do
      with_submit_button
    end
  end
  
end

