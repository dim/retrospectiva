require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/revise_hours.js.rjs" do
  
  before(:each) do
    @story  = assigns[:story]  = stub_model(Story, :revised_hours => 12)    
    @sprint = assigns[:sprint] = stub_model(Sprint)
    template.stub!(:permitted?).and_return(true)
  end

  it "should render the updated hours" do
    render
    response.should have_rjs :replace_html, "story_#{@story.id}_hours", '12'
  end

  it "should render re-render the charts" do
    render
    response.should have_rjs :replace, "sprint_#{@sprint.id}_hours_chart"
    response.should have_rjs :replace, "sprint_#{@sprint.id}_stories_chart"
  end
  
end

