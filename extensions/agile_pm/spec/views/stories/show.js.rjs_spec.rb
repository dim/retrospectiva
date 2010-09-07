require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/show.js.rjs" do
  
  before(:each) do
    @event   = stub_model(StoryComment, :created_at => 3.days.ago)

    @project    = stub_current_project!        
    @user       = stub_current_user! :name => 'Doesnt Matter', :email => 'test@localhost.localdomain'        
    @milestone  = assigns[:milestone] = stub_model(Milestone)    
    @sprint     = assigns[:sprint]    = stub_model(Sprint)
    @story      = assigns[:story] = stub_model(Story, :events => [@event], :title => 'My Story', :created_at => 4.days.ago)    
    @comment    = assigns[:story_comment] = stub_model(StoryComment).as_new_record

    template.stub!(:permitted?).and_return(true)
    template.stub!(:stories_path).and_return('/path/to/stories')
  end

  it "should render the story and all events in the lightbox" do
    render
    response.should have_rjs :replace_html, 'lightbox' do
      with_tag 'h3', 1
      with_tag 'h6', 2
    end
  end

  it "should render navigation links" do
    render
    response.should have_rjs :replace_html, 'lightbox' do
      with_tag 'a', 'Link'
      with_tag 'a', 'Edit'
      with_tag 'a', 'Close'
    end
  end

  it "should render the comment form" do
    render
    response.should have_rjs :replace_html, 'lightbox' do
      with_tag 'form.new_story_comment', 1
    end
  end
  
  
end

