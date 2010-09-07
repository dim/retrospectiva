require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/goals/show.html.erb" do
  
  before(:each) do
    @project = stub_current_project! :name => 'Retrospectiva'   
    assigns[:milestone] = stub_model(Milestone)
    assigns[:goal] = stub_model(Goal, :sprint => stub_model(Sprint, :title => 'Sprint 1'))
    
    template.stub!(:permitted?).and_return(true)
    template.stub!(:sprint_location).and_return('#')
  end

  it "should render the details" do
    render
    response.should have_tag '.agile-pm .box', 1
  end
  
end

