require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/no_sprints.html.erb" do
  
  before(:each) do
    @project = stub_current_project!    
    template.stub!(:permitted?).and_return(true)
  end

  it "should render the message" do
    render
    response.should have_tag '.agile-pm p', 1
  end

  
end
