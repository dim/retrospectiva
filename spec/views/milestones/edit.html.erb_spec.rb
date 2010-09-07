require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/milestones/edit.html.erb" do
  include MilestonesHelper
  
  before do
    @project = stub_current_project!
    @milestone = mock_model Milestone, 
      :name => 'M1', :info => 'I1', 
      :started_on => Date.today, :finished_on => nil, :due => nil
    assigns[:milestone] = @milestone
    render "/milestones/edit.html.erb"
  end

  it "should render edit form" do
    response.should have_form_puting_to(project_milestone_path(@project, @milestone)) do
      with_text_field_for :name
      with_text_field_for :info
      with_submit_button
    end
  end

  it "should show cancel link" do
    response.should have_tag('a[href=?]', project_milestones_path(@project), 'Back')
  end
end




