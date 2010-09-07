require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/goals/edit.html.erb" do
  
  before(:each) do
    @project = stub_current_project! :name => 'Retrospectiva'   
    @milestone = assigns[:milestone] = stub_model(Milestone)
    @goal = assigns[:goal] = stub_model(Goal, :sprint => stub_model(Sprint, :title => 'Sprint 1'))
    assigns[:sprints] = [stub_model(Sprint)]
    assigns[:users] = [stub_model(User)]
    
    template.stub!(:permitted?).and_return(true)
    template.stub!(:sprint_location).and_return('#')
  end

  it "should render the form" do
    render
    response.should have_form_puting_to(project_milestone_goal_path(@project, @milestone, @goal))
  end
  
end

