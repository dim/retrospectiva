require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/sprints/new.html.erb" do
  
  before(:each) do
    @project = stub_current_project! :name => 'Retrospectiva'   
    @milestone = assigns[:milestone] = stub_model(Milestone, :to_param => '37')
    @sprint = assigns[:sprint] = stub_model(Sprint).as_new_record

    template.stub!(:permitted?).and_return(true)
    template.stub!(:sprint_location).and_return('#')
  end

  it "should render the form" do
    render
    response.should have_form_posting_to(project_milestone_sprints_path(@project, @milestone))
  end
  
end

