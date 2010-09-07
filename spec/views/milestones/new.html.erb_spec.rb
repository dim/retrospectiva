require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/milestones/new.html.erb" do
  include MilestonesHelper
  
  before(:each) do
    @project = stub_current_project!
    @milestone = stub_model(Milestone).as_new_record
    assigns[:milestone] = @milestone
    render "/milestones/new.html.erb"
  end

  it "should render new form" do    
    response.should have_form_posting_to(project_milestones_path(@project)) do
      with_text_field_for :name
      with_text_field_for :info
      with_submit_button
    end
  end

  it "should show cancel link" do
    response.should have_tag('a[href=?]', project_milestones_path(@project), 'Back')
  end
end


