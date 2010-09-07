require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TicketReportsController do
  it_should_behave_like EveryProjectAreaController

  before do
    @project = permit_access_with_current_project! :name => 'Retrospectiva'
    @user = stub_current_user! :has_access? => true
    @reports_proxy = []
    @project.stub!(:ticket_reports).and_return(@reports_proxy)
  end

  def mock_ticket_report(stubs={})
    @mock_ticket_report ||= mock_model(TicketReport, stubs)
  end
  
  describe "GET new" do
    it "assigns a new ticket report" do
      @project.should_receive(:ticket_reports).and_return(@reports_proxy)
      @reports_proxy.should_receive(:new).and_return(mock_ticket_report)
      get :new, :project_id => 'retro', :format => 'js'
      assigns[:ticket_report].should == mock_ticket_report
    end
  end

  describe "POST create" do
    
    describe "with valid params" do
      it "assigns a newly created ticket report" do
        @reports_proxy.should_receive(:new).with({'these' => 'params'}).and_return(mock_ticket_report(:save => true))
        post :create, :ticket_report => {:these => 'params'}, :project_id => 'retro', :format => 'js'
        assigns[:ticket_report].should equal(mock_ticket_report)
      end

      it "renders the action" do
        @reports_proxy.stub!(:new).and_return(mock_ticket_report(:save => true))
        post :create, :ticket_report => {}, :project_id => 'retro', :format => 'js'
        response.should render_template(:create)
      end
    end
  
    describe "with invalid params" do
      it "assigns a newly created but unsaved ticket report" do
        @reports_proxy.stub!(:new).with({'these' => 'params'}).and_return(mock_ticket_report(:save => false))
        post :create, :ticket_report => {:these => 'params'}, :project_id => 'retro', :format => 'js'
        assigns[:ticket_report].should equal(mock_ticket_report)
      end

      it "re-renders the 'new' template" do
        @reports_proxy.stub!(:new).and_return(mock_ticket_report(:save => false))
        post :create, :ticket_report => {}, :project_id => 'retro', :format => 'js'
        response.should render_template('new')
      end
    end
    
  end

  describe "DELETE destroy" do
    it "destroys the requested ticket report" do
      @reports_proxy.should_receive(:find).with("37").and_return(mock_ticket_report)
      mock_ticket_report.should_receive(:destroy)
      delete :destroy, :id => "37", :project_id => 'retro'
    end
  
    it "redirects to the ticket list" do
      @reports_proxy.stub!(:find).and_return(mock_ticket_report(:destroy => true))
      delete :destroy, :id => "1", :project_id => 'retro'
      response.should redirect_to(project_tickets_path(@project))
    end
  end

  describe "handling PUT sort" do
    
    before do
      @reports_proxy.stub!(:update_all).and_return(true)
    end
    
    def do_put
      xhr :put, :sort, :project_id => 'retro', :ticket_reports => ['3', '1', '2']        
    end

    it "should update the records" do
      @reports_proxy.should_receive(:update_all).
        with(['rank = ?', 0], ['id = ?', 3]).and_return(true)
      @reports_proxy.should_receive(:update_all).
        with(['rank = ?', 1], ['id = ?', 1]).and_return(true)
      @reports_proxy.should_receive(:update_all).
        with(['rank = ?', 2], ['id = ?', 2]).and_return(true)
      do_put
    end

    it "should render nothing" do
      do_put
      response.should be_success
      response.body.should be_blank
    end

  end

end
