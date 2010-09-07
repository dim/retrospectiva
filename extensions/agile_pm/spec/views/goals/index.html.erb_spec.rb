require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/goals/index.html.erb" do
  
  before(:each) do
    @project = stub_current_project!    
    @sprint = assigns[:current_sprint] = stub_model(Sprint, :title => 'Sprint 1')
    @milestone = assigns[:milestone] = stub_model(Milestone, :sprints => [@sprint, stub_model(Sprint, :title => 'Sprint 2')])
    assigns[:milestones] = [@milestone, stub_model(Milestone)]
    assigns[:goals] = { @sprint => [stub_model(Goal)], nil => [stub_model(Goal)] }
    
    template.stub!(:permitted?).and_return(true)
    template.stub!(:x_stylesheet_link_tag)
    template.stub!(:x_javascript_include_tag)
    template.stub!(:x_image_tag)    
    template.stub!(:x_image_path)    
  end

  it "should render the sprint tables" do
    render
    response.should have_tag '.agile-pm .span-16 table', 3
  end

  it "should render the navigation" do
    render
    response.should have_tag '.agile-pm-navigation h3', 2
  end
  
end

