require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/groups/new.html.erb" do
  
  before(:each) do
    mock_current_user! :admin? => true
    assigns[:group] = @group = mock_model(Group, 
      :name => 'G1', 
      :access_to_all_projects? => true, 
      :access_to_all_projects => true, 
      :permitted? => true)
    assigns[:projects] = [mock_model(Project, :name => 'G1')]
  end

  def do_render
    render "/admin/groups/new.html.erb", :helper => 'admin_area'
  end
    
  it "should render the form" do
    do_render
    response.should have_form_posting_to(admin_groups_path) do
      with_submit_button
      with_link_to(admin_groups_path)
    end
  end

  it "should render the page header" do
    template.should_receive(:render).with(:partial => 'header')
    do_render
  end

end

