require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/wiki/rename.html.erb" do
  
  before(:each) do
    @project = stub_model(Project, :to_param => 'retro')
    @wiki_page = stub_model(WikiPage, :title => 'New', :title_was => 'Old')
    Project.stub!(:current).and_return(@project)
    assigns[:wiki_page] = @wiki_page 
    template.stub!(:x_stylesheet_link_tag).and_return('')
  end

  def do_render
    render "wiki/rename.html.erb"
  end
    
  it "should render without errors" do
    do_render
  end
  
  it "should have a form putting to update-title" do
    do_render
    response.should have_form_puting_to(update_title_project_wiki_page_path(@project, 'Old'))
  end

end

