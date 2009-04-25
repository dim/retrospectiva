require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TicketReportsController do

#  def mock_ticket_report(stubs={})
#    @mock_ticket_report ||= mock_model(TicketReport, stubs)
#  end
#  
#  describe "GET index" do
#    it "assigns all ticket_reports as @ticket_reports" do
#      TicketReport.should_receive(:find).with(:all).and_return([mock_ticket_report])
#      get :index
#      assigns[:ticket_reports].should == [mock_ticket_report]
#    end
#  end
#
#  describe "GET show" do
#    it "assigns the requested ticket_report as @ticket_report" do
#      TicketReport.should_receive(:find).with("37").and_return(mock_ticket_report)
#      get :show, :id => "37"
#      assigns[:ticket_report].should equal(mock_ticket_report)
#    end
#  end
#
#  describe "GET new" do
#    it "assigns a new ticket_report as @ticket_report" do
#      TicketReport.should_receive(:new).and_return(mock_ticket_report)
#      get :new
#      assigns[:ticket_report].should equal(mock_ticket_report)
#    end
#  end
#
#  describe "GET edit" do
#    it "assigns the requested ticket_report as @ticket_report" do
#      TicketReport.should_receive(:find).with("37").and_return(mock_ticket_report)
#      get :edit, :id => "37"
#      assigns[:ticket_report].should equal(mock_ticket_report)
#    end
#  end
#
#  describe "POST create" do
#    
#    describe "with valid params" do
#      it "assigns a newly created ticket_report as @ticket_report" do
#        TicketReport.should_receive(:new).with({'these' => 'params'}).and_return(mock_ticket_report(:save => true))
#        post :create, :ticket_report => {:these => 'params'}
#        assigns[:ticket_report].should equal(mock_ticket_report)
#      end
#
#      it "redirects to the created ticket_report" do
#        TicketReport.stub!(:new).and_return(mock_ticket_report(:save => true))
#        post :create, :ticket_report => {}
#        response.should redirect_to(ticket_report_url(mock_ticket_report))
#      end
#    end
#    
#    describe "with invalid params" do
#      it "assigns a newly created but unsaved ticket_report as @ticket_report" do
#        TicketReport.stub!(:new).with({'these' => 'params'}).and_return(mock_ticket_report(:save => false))
#        post :create, :ticket_report => {:these => 'params'}
#        assigns[:ticket_report].should equal(mock_ticket_report)
#      end
#
#      it "re-renders the 'new' template" do
#        TicketReport.stub!(:new).and_return(mock_ticket_report(:save => false))
#        post :create, :ticket_report => {}
#        response.should render_template('new')
#      end
#    end
#    
#  end
#
#  describe "PUT udpate" do
#    
#    describe "with valid params" do
#      it "updates the requested ticket_report" do
#        TicketReport.should_receive(:find).with("37").and_return(mock_ticket_report)
#        mock_ticket_report.should_receive(:update_attributes).with({'these' => 'params'})
#        put :update, :id => "37", :ticket_report => {:these => 'params'}
#      end
#
#      it "assigns the requested ticket_report as @ticket_report" do
#        TicketReport.stub!(:find).and_return(mock_ticket_report(:update_attributes => true))
#        put :update, :id => "1"
#        assigns[:ticket_report].should equal(mock_ticket_report)
#      end
#
#      it "redirects to the ticket_report" do
#        TicketReport.stub!(:find).and_return(mock_ticket_report(:update_attributes => true))
#        put :update, :id => "1"
#        response.should redirect_to(ticket_report_url(mock_ticket_report))
#      end
#    end
#    
#    describe "with invalid params" do
#      it "updates the requested ticket_report" do
#        TicketReport.should_receive(:find).with("37").and_return(mock_ticket_report)
#        mock_ticket_report.should_receive(:update_attributes).with({'these' => 'params'})
#        put :update, :id => "37", :ticket_report => {:these => 'params'}
#      end
#
#      it "assigns the ticket_report as @ticket_report" do
#        TicketReport.stub!(:find).and_return(mock_ticket_report(:update_attributes => false))
#        put :update, :id => "1"
#        assigns[:ticket_report].should equal(mock_ticket_report)
#      end
#
#      it "re-renders the 'edit' template" do
#        TicketReport.stub!(:find).and_return(mock_ticket_report(:update_attributes => false))
#        put :update, :id => "1"
#        response.should render_template('edit')
#      end
#    end
#    
#  end
#
#  describe "DELETE destroy" do
#    it "destroys the requested ticket_report" do
#      TicketReport.should_receive(:find).with("37").and_return(mock_ticket_report)
#      mock_ticket_report.should_receive(:destroy)
#      delete :destroy, :id => "37"
#    end
#  
#    it "redirects to the ticket_reports list" do
#      TicketReport.stub!(:find).and_return(mock_ticket_report(:destroy => true))
#      delete :destroy, :id => "1"
#      response.should redirect_to(ticket_reports_url)
#    end
#  end

end
