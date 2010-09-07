require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/projects/new.html.erb" do
  
  before(:each) do
    stub_current_user! :admin? => true
    assigns[:project] = @project = stub_model(Project, :short_name_was => 'any', :short_name => 'any').as_new_record
    assigns[:repositories] = [stub_model(Repository::Git, :name => 'R1')]
  end

  def do_render
    render "/admin/projects/new.html.erb", :helper => 'admin_area'
  end
    
  it "should render the form" do
    do_render
    response.should have_form_posting_to(admin_projects_path) do
      with_submit_button
      with_link_to(admin_projects_path)
    end
  end

  it "should render the page header" do
    template.should_receive(:render).with(:partial => 'header')
    do_render
  end

end

