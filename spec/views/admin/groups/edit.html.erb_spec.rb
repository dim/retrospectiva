require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe "/admin/groups/edit.html.erb" do
  
  before(:each) do
    stub_current_user! :admin? => true
    assigns[:group] = @group = stub_model(Group, :project_names => %w(P1 P2))
    assigns[:projects] = [mock_model(Project, :name => 'P1')]
  end

  def do_render
    render "/admin/groups/edit.html.erb", :helper => 'admin_area'
  end
    
  it "should render the form" do
    do_render
    response.should have_form_puting_to(admin_group_path(@group)) do
      with_submit_button
      with_link_to(admin_groups_path)
    end
  end
  
  it "should render the page header" do
    template.should_receive(:render).with(:partial => 'header')
    do_render
  end

end

