require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/update_progress.js.rjs" do
  
  before(:each) do
    @story  = assigns[:story]  = stub_model(Story)
    @sprint = assigns[:sprint] = stub_model(Sprint)
    @update = assigns[:progress_update] = stub_model(StoryProgressUpdate, :percent_completed => 80)
    template.stub!(:permitted?).and_return(true)
  end

  it "should render the updated progress" do
    render
    response.should have_rjs :replace_html, "story_#{@story.id}_progress", '80%'
  end

  it "should render re-render the charts" do
    render
    response.should have_rjs :replace, "sprint_#{@sprint.id}_hours_chart"
    response.should have_rjs :replace, "sprint_#{@sprint.id}_stories_chart"
  end
  
end

