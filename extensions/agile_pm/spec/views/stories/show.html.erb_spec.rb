require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/show.html.erb" do
  
  before(:each) do
    @event   = stub_model(StoryComment, :created_at => 3.days.ago)
    @story   = assigns[:story] = stub_model(Story, :events => [@event], :title => 'My Story', :created_at => 4.days.ago)    
    template.stub!(:permitted?).and_return(true)
    template.stub!(:stories_path).and_return('/path/to/stories')
    template.stub!(:edit_story_path).and_return('/path/to/story/123/edit')
  end

  it "should render the story and all events" do
    render
    response.should have_tag '.agile-pm h3', 1
    response.should have_tag '.agile-pm h6', 2
  end
  
end

