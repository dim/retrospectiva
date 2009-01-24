require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::ReportsController do
  def nested_controller_options
    { :project_id => 'retro' }
  end  
  it_should_behave_like EveryAdminAreaController

  before do
    permit_access!
    @project = mock_model(Project)
    Project.stub!(:find_by_short_name).and_return(@project)
    @ticket_reports = [mock_model(TicketReport)]
    @project.stub!(:ticket_reports).and_return(@ticket_reports)
  end

  def self.it_should_find_the_related_project(method = :do_get)
    it "should find the related project" do
      Project.should_receive(:find_by_short_name).and_return(@project)
      send(method)
      assigns[:project].should == @project
    end
  end
  
  describe "handling GET /admin/project_name/reports" do

    def do_get
      get :index, :project_id => 'retro'
    end

    it_should_successfully_render_template('index')
    it_should_find_the_related_project
    
    it "should find the ticket reports" do
      @project.should_receive(:ticket_reports).and_return(@ticket_reports)
      do_get
    end

    it "should assign the ticket reports for the view" do
      do_get
      assigns[:ticket_reports].should == @ticket_reports
    end

  end


  describe "handling GET /admin/project_name/reports/new" do
    
    before do
      @ticket_report = mock_model(TicketReport)
      @ticket_reports.stub!(:new).and_return(@ticket_report)
    end

    def do_get
      get :new, :project_id => 'retro'
    end      

    it_should_successfully_render_template('new')
    it_should_find_the_related_project

    it "should create a new ticket report" do
      @ticket_reports.should_receive(:new).with(nil).and_return(@ticket_report)
      do_get
    end

    it "should not save the ticket report" do
      @ticket_report.should_not_receive(:save)
      do_get
    end

    it "should assign the ticket report for the view" do
      do_get
      assigns[:ticket_report].should == @ticket_report
    end

  end


  describe "handling POST /admin/project_name/reports" do
    
    before do
      @ticket_report = mock_model(TicketReport)
      @ticket_reports.stub!(:new).and_return(@ticket_report)
    end

    def do_post(success = true)
      @ticket_report.stub!(:save).and_return(success)
      post :create, :project_id => 'retro', :ticket_report => {}
    end      

    it_should_find_the_related_project(:do_post)

    it "should create a new ticket report" do
      @ticket_reports.should_receive(:new).with({}).and_return(@ticket_report)
      do_post
    end

    describe 'with valid attributes' do

      it "should save the ticket report" do
        @ticket_report.should_receive(:save).and_return(true)
        do_post(true)
      end

      it "should redirect to ticket report index" do
        do_post(true)
        response.should be_redirect
        response.should redirect_to(admin_project_reports_path(@project))
      end
      
    end

    describe 'with invalid attributes' do

      def do_post
        super(false)
      end
      
      it "should not save the ticket report" do
        @ticket_report.should_receive(:save).and_return(false)
        do_post
      end

      it_should_successfully_render_template('new', :do_post)      
    end

  end


  describe "handling GET /admin/project_name/reports/1/edit" do
    
    before do
      @ticket_report = mock_model(TicketReport, :to_param => '1')
      @ticket_reports.stub!(:find).and_return(@ticket_report)
    end

    def do_get
      get :edit, :project_id => 'retro', :id => '1'
    end      

    it_should_successfully_render_template('edit')

    it_should_find_the_related_project

    it "should find the ticket report" do
      @ticket_reports.should_receive(:find).with('1').and_return(@ticket_report)
      do_get
    end

    it "should not update the ticket report" do
      @ticket_report.should_not_receive(:save)
      do_get
    end

    it "should assign the ticket report for the view" do
      do_get
      assigns[:ticket_report].should == @ticket_report
    end

  end


  describe "handling PUT /admin/project_name/reports/1" do
    
    before do
      @ticket_report = mock_model(TicketReport, :to_param => '1')
      @ticket_reports.stub!(:find).and_return(@ticket_report)
    end

    def do_put(success = true)
      @ticket_report.stub!(:update_attributes).and_return(success)
      put :update, :project_id => 'retro', :id => '1', :ticket_report => {}
    end      

    it_should_find_the_related_project(:do_put)

    it "should find the ticket report" do
      @ticket_reports.should_receive(:find).with('1').and_return(@ticket_report)
      do_put
    end

    describe 'with valid attributes' do

      it "should save the ticket report" do
        @ticket_report.should_receive(:update_attributes).with({}).and_return(true)
        do_put(true)
      end

      it "should redirect to ticket report index" do
        do_put(true)
        response.should be_redirect
        response.should redirect_to(admin_project_reports_path(@project))
      end      
      
    end

    describe 'with invalid attributes' do

      def do_put
        super(false)
      end
      
      it "should not save the ticket report" do
        @ticket_report.should_receive(:update_attributes).with({}).and_return(false)
        do_put
      end

      it_should_successfully_render_template('edit', :do_put)
      
    end

  end



  describe "handling DELETE /admin/project_name/reports/1" do
    
    before do
      @ticket_report = mock_model(TicketReport, :to_param => '1')
      @ticket_reports.stub!(:destroy).and_return(@ticket_report)
    end

    def do_delete
      delete :destroy, :project_id => 'retro', :id => '1'
    end      

    it_should_find_the_related_project(:do_delete)

    it "should delete the ticket report" do
      @ticket_reports.should_receive(:destroy).with('1').and_return(@ticket_report)
      do_delete
    end

    it "should redirect to ticket report index" do
      do_delete
      response.should be_redirect
      response.should redirect_to(admin_project_reports_path(@project))
    end

  end


  describe "handling PUT /admin/project_name/reports/sort" do
    
    before do
      TicketReport.stub!(:update_all).and_return(true)
    end
    
    def do_put
      xhr :put, :sort, :project_id => 'retro', :ticket_reports => ['3', '1', '2']        
    end

    it_should_find_the_related_project(:do_put)
    
    it "should update the records" do
      TicketReport.should_receive(:update_all).
        with(['rank = ?', 0], ['id = ? AND project_id = ?', 3, @project.id]).and_return(true)
      TicketReport.should_receive(:update_all).
        with(['rank = ?', 1], ['id = ? AND project_id = ?', 1, @project.id]).and_return(true)
      TicketReport.should_receive(:update_all).
        with(['rank = ?', 2], ['id = ? AND project_id = ?', 2, @project.id]).and_return(true)
      do_put
    end

    it "should render nothing" do
      do_put
      response.should be_success
      response.body.should be_blank
    end

  end

end
