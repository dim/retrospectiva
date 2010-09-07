require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/sprints/edit.html.erb" do
  
  before(:each) do
    @project = stub_current_project! :name => 'Retrospectiva'   
    @milestone = assigns[:milestone] = stub_model(Milestone)
    @sprint = assigns[:sprint] = stub_model(Sprint)

    template.stub!(:permitted?).and_return(true)
    template.stub!(:sprint_location).and_return('#')
  end

  it "should render the form" do
    render
    response.should have_form_puting_to(project_milestone_sprint_path(@project, @milestone, @sprint))
  end
  
end

