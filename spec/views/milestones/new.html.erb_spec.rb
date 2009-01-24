require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/milestones/new.html.erb" do
  include MilestonesHelper
  
  before(:each) do
    @project = mock_current_project!
    @milestone = mock_model Milestone, 
      :name => 'M1', :info => 'I1', 
      :started_on => Date.today, :finished_on => nil, :due => nil
    @milestone.stub!(:new_record?).and_return(true)
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


