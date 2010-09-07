require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/backlog.html.erb" do
  
  before(:each) do
    @project = stub_current_project!        

    @stories = [stub_model(Story), stub_model(Story), stub_model(Story)]
    @stories.stub!(:active_count).and_return(1)
    @stories.stub!(:pending_count).and_return(1)
    @stories.stub!(:completed_count).and_return(1)
    @stories.stub!(:by_status).and_return(@stories)
    
    @sprint  = assigns[:sprint] = stub_model(Sprint, :title => 'Sprint 1', :stories => @stories, :starts_on => 10.days.ago.to_date, :finishes_on => 4.days.from_now.to_date)
    @milestone = assigns[:milestone] = stub_model(Milestone, :sprints => [@sprint, stub_model(Sprint, :title => 'Sprint 2')])    
    
    template.stub!(:permitted?).and_return(true)
    template.stub!(:x_stylesheet_link_tag)
    template.stub!(:stories_path).and_return('/path/to/stories')
  end

  it "should render the backlog" do
    render
    response.should have_tag '.agile-pm table.backlog', 1
  end
  
end

