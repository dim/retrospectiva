require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/stories/new.html.erb" do
  
  before(:each) do
    @project = stub_current_project!

    @sprint = assigns[:sprint] = stub_model(Sprint, :goals => [stub_model(Goal)])
    @story  = assigns[:story]  = stub_model(Story)        
    
    template.stub!(:permitted?).and_return(true)
    template.stub!(:stories_path).and_return('/path/to/stories')
  end

  it "should render the form" do
    render
    response.should have_tag '.agile-pm form' do
      with_tag 'fieldset', 5
    end
  end

  
end
