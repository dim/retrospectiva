require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/index.html.erb" do
  
  before(:each) do
    @project = stub_current_project!        

    @user_a  = stub_current_user!
    @user_b  = stub_model(User)
    
    @stories   = assigns[:stories]   = { @user_a => [ stub_model(Story), stub_model(Story) ], @user_b => stub_model(Story) }    
    @sprint    = assigns[:sprint]    = stub_model(Sprint, :title => 'Sprint 1', :starts_on => 10.days.ago.to_date, :finishes_on => 4.days.from_now.to_date)
    @milestone = assigns[:milestone] = stub_model(Milestone, :sprints => [@sprint, stub_model(Sprint, :title => 'Sprint 2')])    
    
    assigns[:milestones] = [@milestone, stub_model(Milestone, :sprints => [])]
    
    template.stub!(:permitted?).and_return(true)
    template.stub!(:x_stylesheet_link_tag)
    template.stub!(:x_javascript_include_tag)
    template.stub!(:stories_path).and_return('/path/to/stories')
  end

  it "should render the stories table" do
    render
    response.should have_tag '.agile-pm table', 1
    response.should have_tag '.agile-pm table tr', 5
  end

  it "should render the navigation" do
    render
    response.should have_tag '.agile-pm .agile-pm-navigation .box', 1
  end

  it "should render progress stats" do
    render
    response.should have_tag '.agile-pm .agile-pm-navigation h4', 2
  end
  
end

