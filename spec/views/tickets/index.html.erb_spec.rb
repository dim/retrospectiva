require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/tickets/index.html.erb" do
  
  before(:each) do
    template.stub!(:auto_discover_feed)
    @user = stub_current_user! :permitted? => false, :public? => false
    @project = stub_current_project! :ticket_property_types => []
    @status = mock_model Status, 
      :state => mock_model(Status::State, :group => 'All Open', :type => 'Open'), 
      :statement => mock_model(Status::Statement, :type => 'Positive'), 
      :name => 'S1'
    @priority = mock_model Priority, :name => 'Urgent'
    @milestone = mock_model Milestone, :name => 'First Release'
    @ticket = mock_model Ticket, 
      :status => @status, 
      :priority => @priority,
      :milestone => @milestone,
      :subscribers => [],
      :summary => 'This is the ticket\'s summary',
      :content => 'This is the ticket\'s content',
      :user => nil,
      :assigned_user => nil,
      :author => 'Me',
      :email => '',
      :created_at => 2.days.ago,
      :updated_at => 2.days.ago,
      :changes => [],
      :updated? => false
    ticket_2 = mock_model Ticket

    @filters = mock_model TicketFilter::Collection, :default? => true, :map => [], :to_params => {}
    
    assigns[:tickets] = [@ticket, ticket_2].paginate(:per_page => 1)
    assigns[:reports] = [] 
    assigns[:filters] = @filters 
  end

  describe 'in general' do    

    def do_render
      render "/tickets/index.html.erb"
    end
    
    it "should render list of tickets" do
      do_render
      response.should have_tag('table tbody#tickets tr', 1)
    end

    it "should show a link to toggle the ticket filter" do
      do_render
      response.should have_tag('a', 'Filter tickets')
    end

    describe 'if no reports are pre-defined' do

      it "should NOT show a link to toggle the reports selector" do
        do_render
        response.should_not have_tag('a', 'Show report')
      end
      
    end

    describe 'if reports are pre-defined' do
      
      before do
        assigns[:reports] = [mock_model(TicketReport, :user_specific? => true, :name => 'My Report')]
      end

      it "should show a link to toggle the reports selector" do
        do_render
        response.should have_tag('a', 'Show report')
      end
      
    end


  end

  it "needs proper implementation"

end
