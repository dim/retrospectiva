require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tickets/search.js.rjs" do
  
  before(:each) do
    @user = stub_current_user! :permitted? => false
    @project = stub_current_project! :ticket_property_types => []
    @status = stub_model Status, 
      :state => Status.state(1), 
      :statement => Status.statement(1)
    @priority = stub_model Priority
    @ticket = stub_model Ticket, 
      :status => @status, 
      :priority => @priority, 
      :subscribers => [], 
      :created_at => 2.weeks.ago, 
      :updated? => false 
    assigns[:tickets] = [@ticket] 
  end

  def do_render
    render '/tickets/search.js.rjs'
  end

  it "should show only matching tickets" do
    do_render
    response.should have_rjs('tickets') do 
      response.should have_tag('tr td', 7)
    end
  end

end
