require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/goals/no_milestones.html.erb" do
  
  before(:each) do
    @project = stub_current_project! :name => 'Retrospectiva'     
    template.stub!(:permitted?).and_return(true)
    template.stub!(:x_stylesheet_link_tag)
  end

  it "should render the info line" do
    render
    response.should have_tag '.agile-pm p', 1
  end
  
end

