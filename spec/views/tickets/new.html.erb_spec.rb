require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tickets/new.html.erb" do
  
  before(:each) do
    @user = stub_current_user! :permitted? => false, :public? => false
    @project = stub_current_project!
    @project.stub_association!(:users, :with_permission => [])
    @milestones = @project.stub_association!(:milestones, :active_on => [])
    @milestones.stub!(:in_default_order).and_return(@milestones)
    
    @property_type = mock_model(TicketPropertyType, :name => 'Component', :ticket_properties => [mock_model(TicketProperty)])
    @project.stub!(:ticket_property_types).and_return([@property_types])

    assigns[:ticket] = mock_model Ticket, 
      :author => nil, :email => nil, :summary => nil, :content => nil,
      :status_id => nil, :priority_id => nil, :milestone_id => nil,
      :assigned_user_id => nil, :created_at => nil, :property_ids => []
  end

  def do_render
    render '/tickets/new'
  end

  it "should render a from" do
    do_render
    response.should have_form_posting_to(project_tickets_path(@project))
  end

end
  