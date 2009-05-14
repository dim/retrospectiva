require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/projects/edit.html.erb" do
  
  before(:each) do
    mock_current_user! :admin? => true
    assigns[:project] = @project = mock_model(Project, :name => 'P1', 
      :locale => nil, :repository_id => nil, :root_path => nil, :enabled_modules => [], 
      :closed => false, :info => 'I1', :central => false, :short_name_was => 'p1')
    assigns[:repositories] = [mock_model(Repository::Abstract, :name => 'R1')]
  end

  def do_render
    render "/admin/projects/edit.html.erb", :helper => 'admin_area'
  end
    
  it "should render the form" do
    do_render
    response.should have_form_puting_to(admin_project_path(@project)) do
      with_submit_button
      with_link_to(admin_projects_path)
    end
  end
  
  it "should render the page header" do
    template.should_receive(:render).with(:partial => 'header')
    do_render
  end

end

