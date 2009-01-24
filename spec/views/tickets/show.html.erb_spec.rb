require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tickets/show.html.erb" do
  
  before(:each) do
    @user = mock_current_user! :permitted? => false
    @project = mock_current_project!
  end

  def do_render
    render '/tickets/show'
  end

  it "needs proper implementation"

end
