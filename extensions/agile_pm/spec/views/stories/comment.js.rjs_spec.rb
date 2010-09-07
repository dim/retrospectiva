require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/comment.js.rjs" do
  
  before(:each) do
    @user    = stub_current_user! :name => 'Doesnt Matter', :email => 'test@localhost.localdomain'   
    @project = stub_current_project! :name => 'Retrospectiva'   
    @sprint = assigns[:sprint] = stub_model(Sprint)
    @milestone = assigns[:milestone] = stub_model(Milestone)

    @event   = stub_model(StoryComment, :created_at => 3.days.ago)
    @story   = assigns[:story] = stub_model(Story, :events => [@event], :title => 'My Story', :created_at => 4.days.ago)    
    @comment = assigns[:story_comment] = stub_model(StoryComment)
    template.stub!(:permitted?).and_return(true)
  end

  it "should render the details in a lightbox when no errors" do
    render
    response.should have_rjs :replace_html, 'lightbox' do
      with_tag 'h3', /My Story/
    end
  end

  it "should render re-render the form on errors" do
    @comment.errors.add :content, :blank
    render
    response.should have_rjs :replace, 'story_comment_form' do
      with_tag 'div#story_comment_form'
    end
  end
  
end

