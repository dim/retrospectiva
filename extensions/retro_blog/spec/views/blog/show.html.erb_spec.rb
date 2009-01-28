require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/blog/show.html.erb" do
  
  before(:each) do
    @project = stub_model(Project, :to_param => 'retro')
    @comments = [mock_model(BlogComment, :author => 'A', :content => 'C1'), mock_model(BlogComment, :author => 'B', :content => 'C2')]    
    @blog_post = stub_model(BlogPost, :title => 'Title', :content => 'Content', :comments => @comments)
    Project.stub!(:current).and_return(@project)
    assigns[:blog_post] = @blog_post 
  end

  def do_render
    render "blog/show.html.erb"
  end
    
  it "should render without errors"
  it "should render without errors (from the comments-controller)"
  
end

