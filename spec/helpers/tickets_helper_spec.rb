require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TicketsHelper do
  
  describe 'generating the search path hash for tickets (hash_for_search_tickets_path)' do
           
    before do
      @default_params = { :controller => 'tickets', :action => 'search', :format => :js, :project_id => 'project_name', :only_path => true, :use_route => :search_project_tickets }
      Project.stub!(:current).and_return(mock_model(Project, :to_param => 'project_name'))
      assigns[:filters] = @filters = mock(TicketFilter::Collection, :to_params => {})
      helper.stub!(:params).and_return({})
    end
    
    it "should should generate the correct path" do
      helper.hash_for_search_tickets_path.should == @default_params
    end

    it "should include params from the ticket filters" do
      @filters.should_receive(:to_params).and_return(:state => [1,2,3])
      helper.hash_for_search_tickets_path.
        should == @default_params.merge(:state => [1,2,3])
    end

    it "should keep the report params" do
      helper.stub!(:params).and_return(:report => '1')
      helper.hash_for_search_tickets_path.
        should == @default_params.merge(:report => '1')
    end

    it "should ignore any other params" do
      helper.stub!(:params).and_return(:other => '1')
      helper.hash_for_search_tickets_path.
        should == @default_params
    end
    
  end

  
  describe 'HTML class generators for ticket' do

    before do
      @state = mock(Status::State, :type => :in_progress)
      @statement = mock(Status::Statement, :type => :neutral)
      @status = mock_model(Status, :statement => @statement, :state => @state)
      @ticket = mock_model(Ticket, :status => @status)
    end
    
    it "should generate the HTML class name based on the statement of ticket\'s status" do          
      helper.send(:html_class_for_ticket_statement, @ticket).should == 'ticket-statement-neutral'
    end

    it "should generate the HTML class name based on the state of ticket\'s status" do          
      helper.send(:html_class_for_ticket_state, @ticket).should == 'ticket-state-in-progress'
    end

    it "should generate the HTML style class based on the state of ticket\'s status" do          
      helper.html_classes_for_ticket(@ticket).should == 'ticket-state-in-progress ticket-statement-neutral'
    end
    
  end
  
  describe 'displaying the content of the last ticket change in one line' do

    before do
      helper.stub!(:datetime_format).and_return('[DATETIME]')
      @ticket_change = mock_model(TicketChange, :content => "Line1\nLine2\r\nLine3", :author => 'Me')
      @ticket = mock_model(Ticket, :changes => [@ticket_change], :updated_at => 1.month.ago)
    end
    
    it 'should return an empty string if no change is present' do
      @ticket.should_receive(:changes).and_return([])
      helper.last_change_content_one_line(@ticket).should == '[DATETIME]' 
    end

    it 'should return the line-up conent if change is present' do
      helper.should_receive(:datetime_format).and_return('[DATETIME]')
      helper.should_receive(:truncate).with("Line1 Line2 Line3", :length => 600).and_return('[CONTENT]')
      helper.last_change_content_one_line(@ticket).should == 'Me ([DATETIME]): [CONTENT]' 
    end
    
  end
  
end
