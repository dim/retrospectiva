require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/edit.html.erb" do
  
  before(:each) do
    @sprint = assigns[:sprint] = stub_model(Sprint, :goals => [stub_model(Goal)])
    @story   = assigns[:story] = stub_model(Story, :title => 'My Story', :created_at => 4.days.ago)
    template.stub!(:permitted?).and_return(true)
    template.stub!(:story_path).and_return('/path/to/story/123')
    template.stub!(:stories_path).and_return('/path/to/stories')
  end

  it "should render the form" do
    render
    response.should have_tag '.agile-pm form' do
      with_tag 'fieldset', 5
    end
  end
  
end

