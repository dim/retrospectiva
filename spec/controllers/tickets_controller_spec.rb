require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TicketsController do
  it_should_behave_like EveryProjectAreaController

  before do      
    Status.stub!(:default).and_return(stub_model(Status))
    Priority.stub!(:default).and_return(stub_model(Priority))
  end

  before do
    @project = permit_access_with_current_project! :name => 'Any'
    @tickets = [stub_model(Ticket)]
    @tickets_proxy = @project.stub_association!(:tickets)
    @tickets_proxy.stub!(:count)
    @tickets_proxy.stub!(:maximum)
    @changes_proxy = @project.stub_association!(:ticket_changes)
    @user = stub_current_user! :public? => false, :name => 'Agent', :email => 'agent@mail.com' 
  end

  describe "handling GET /tickets" do

    before do
      @tickets_proxy.stub!(:paginate).and_return(@tickets)

      @report = mock_model(TicketReport, :filter_options => {'custom' => '1'}, :since => nil)
      @reports_proxy = @project.stub_association!(:ticket_reports)
      @reports_proxy.stub!(:find_by_id).and_return(nil)
      @reports_proxy.stub!(:find).and_return([@report])

      @filters = mock('TicketFilter::Collection', :joins => nil, :conditions => nil)
      TicketFilter::Collection.stub!(:new).and_return(@filters)

      Ticket.stub!(:default_includes).and_return([:DEFAULTS])
    end

    def do_get(options = {})
      get :index, options.merge(:project_id => @project.to_param)
    end

    it "should check freshness" do
      @tickets_proxy.should_receive(:count)
      @tickets_proxy.should_receive(:maximum).with(:updated_at)
      do_get
    end

    it "should render the template" do
      do_get
      response.should be_success
      response.should render_template(:index)
    end

    it "should generate the ticket filters" do
      TicketFilter::Collection.should_receive(:new).with({'project_id'=>@project.to_param, 'action'=>'index', 'controller'=>'tickets'}, @project).and_return(@filters)
      do_get
      assigns[:filters].should == @filters
    end

    it "should load and assign the reports" do
      @reports_proxy.should_receive(:find).with(:all ,:order => 'rank').and_return([@report])
      do_get
      assigns[:reports].should == [@report]
    end

    it 'should load and assign the tickets' do
      @tickets_proxy.should_receive(:paginate).with({
        :joins=>nil, :conditions=>nil,
        :order=>"tickets.updated_at DESC, ticket_changes.created_at",
        :page=>nil, :per_page=>nil, :total_entries=>nil,
        :include=>[:DEFAULTS]
      }).and_return(@tickets)
      do_get
      assigns[:tickets].should == @tickets
    end


    describe "if a search term is given" do

      def do_get
        super(:term => 'TERM')
      end

      before do
        Retro::Search.stub!(:conditions).and_return(['id = ?', 1])
      end

      it 'should limit the tickets' do
        Retro::Search.should_receive(:conditions).with('TERM', *Ticket.searchable_column_names).and_return(['content = ?', 'TERM'])
        @tickets_proxy.should_receive(:paginate).with({
          :joins=>nil,
          :conditions=>["( content = ? )", 'TERM'],
          :order=>"tickets.updated_at DESC, ticket_changes.created_at",
          :page=>nil, :per_page=>nil, :total_entries=>nil,
          :include=>[:DEFAULTS]
        }).and_return(@tickets)
        do_get
      end

    end


    describe "if a report is specified" do

      def do_get
        super(:report => '1')
      end

      before do
        @report.stub!(:since).and_return('[SINCE]')
        @reports_proxy.stub!(:find_by_id).and_return(@report)
      end

      it "should find the report" do
        @reports_proxy.should_receive(:find_by_id).with('1').and_return(@report)
        do_get
      end

      it "should auto-apply the filters" do
        do_get
        assigns[:report].should == @report
        controller.params.should == {'project_id'=>@project.to_param, "action"=>"index", "controller"=>"tickets", "report"=>"1", "custom"=>"1"}
      end

      it 'should limit the tickets' do
        @tickets_proxy.should_receive(:paginate).with({
          :joins=>nil,
          :conditions=>['( tickets.updated_at > ? )', '[SINCE]'],
          :order=>"tickets.updated_at DESC, ticket_changes.created_at",
          :page=>nil, :per_page=>nil, :total_entries=>nil,
          :include=>[:DEFAULTS]
        }).and_return(@tickets)
        do_get
      end

    end
  end


  describe "handling GET /tickets.rss" do
    before(:each) do
      @tickets_proxy.stub!(:paginate).and_return(@tickets)
      Ticket.stub!(:to_rss).and_return("RSS")

      @reports_proxy = @project.stub_association!(:ticket_reports, :find_by_id => nil, :find => [])
      TicketFilter::Collection.stub!(:new).and_return mock('TicketFilter::Collection', :joins => [:status], :conditions => ['1 = 0'])
      Ticket.stub!(:default_includes).and_return([:DEFAULTS])
    end

    def do_get(options = {})
      get :index, options.merge(:project_id => @project.to_param, :format => 'rss')
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all tickets" do
      @tickets_proxy.should_receive(:paginate).with(
        :order=>"tickets.updated_at DESC, ticket_changes.created_at",
        :page=>nil, :per_page=>10, :total_entries=>10,
        :include=>[:DEFAULTS], :joins=>nil,
        :conditions=>nil).
        and_return(@tickets)
      do_get
    end

    it "should render the found tickets as RSS" do
      Ticket.should_receive(:to_rss).with(@tickets, {}).and_return("RSS")
      do_get
      response.body.should == "RSS"
      response.content_type.should == "application/rss+xml"
    end
  end


  describe "handling GET /tickets/search" do

    before(:each) do
      @tickets_proxy.stub!(:paginate).and_return(@tickets)
      @reports_proxy = @project.stub_association!(:ticket_reports, :find_by_id => nil, :find => [])
      TicketFilter::Collection.stub!(:new).and_return mock('TicketFilter::Collection', :joins => nil, :conditions => nil)
      Ticket.stub!(:default_includes).and_return([:DEFAULTS])
    end

    def do_get(options={})
      get :search, options.merge(:project_id => @project.to_param, :term => 'name')
    end

    it "should render the template" do
      do_get
      response.should be_success
      response.should render_template(:search)
    end

    it 'should load and assign the matching tickets' do
      Retro::Search.should_receive(:conditions).with('name', *Ticket.searchable_column_names).and_return(['content = ?', 'name'])
      @tickets_proxy.should_receive(:paginate).with(
        :order=>"tickets.updated_at DESC, ticket_changes.created_at",
        :page=>nil, :per_page=>nil, :total_entries=>30, 
        :include=>[:DEFAULTS], :joins=>nil,
        :conditions=>["( content = ? )", 'name']).
        and_return(@tickets)
      do_get
      assigns[:tickets].should == @tickets
    end

  end


  describe "handling GET /ticket/1" do

    before do      
      @previous = mock_model(Ticket)
      @next = mock_model(Ticket)

      @ticket_change = mock_model(TicketChange, :attributes= => {})

      @ticket = mock_model(Ticket, :next_ticket => @next, :previous_ticket => @previous, :updated_at => 2.minutes.ago)
      @tickets_proxy.stub!(:find_by_id).and_return(@ticket)

      @changes_proxy = @ticket.stub_association!(:changes, :new => @ticket_change)
      Ticket.stub!(:default_includes).and_return([:DEFAULTS])

      @filters = mock_model(TicketFilter::Collection)
      TicketFilter::Collection.stub!(:new).and_return(@filters)
    end

    def do_get(options = {})
      get :show, options.merge(:project_id => @project.to_param, :id => '1')
    end

    it 'should grab the list params from the user session and create the filters' do
      stored = {:page => 2, :state => [1]}
      controller.session[:params_keeper] = {'tickets/index' => stored}
      controller.should_receive(:stored_params).and_return(stored)
      TicketFilter::Collection.should_receive(:new).with(stored, @project).and_return(@filters)
      do_get
    end

    it 'should find and assign the ticket (incuding associtaions)' do
      @tickets_proxy.should_receive(:find_by_id).with('1', :order => 'ticket_changes.created_at', :include => [:DEFAULTS]).and_return(@ticket)
      do_get
      assigns[:ticket].should == @ticket
    end

    it 'should check freshness' do
      @ticket.should_receive(:updated_at)
      do_get
    end

    it 'should redirect to list if ticket cannot be found' do
      @tickets_proxy.should_receive(:find_by_id).and_return(nil)
      do_get
      response.should be_redirect
      response.should redirect_to(project_tickets_path(@project))
    end

    it 'should find the next ticket' do
      @ticket.should_receive(:next_ticket).with(@filters).and_return(@next)
      do_get
      assigns[:next_ticket].should == @next
    end

    it 'should find the previous ticket' do
      @ticket.should_receive(:previous_ticket).with(@filters).and_return(@previous)
      do_get
      assigns[:previous_ticket].should == @previous
    end

    it 'should build and assign the ticket change' do
      @changes_proxy.should_receive(:new).and_return(@ticket_change)
      @ticket_change.should_receive(:attributes=).with({})
      @ticket_change.should_receive(:attributes=).with(:author => 'Agent', :email => 'agent@mail.com')
      do_get
      assigns[:ticket_change].should == @ticket_change
    end

    it 'should successfully render the template' do
      do_get
      response.should be_success
      response.should render_template(:show)
    end

  end


  describe "handling GET /tickets/new" do

    before do
      @ticket = Ticket.new
      @tickets_proxy.stub!(:new).and_return @ticket
      controller.stub!(:cached_user_attribute)
    end

    def do_get(params = {})
      get :new, params.merge(:project_id => @project.to_param) 
    end

    it 'should initialize a new ticket' do
      @tickets_proxy.should_receive(:new).with({ 'author' => 'Me' }).and_return @ticket
      do_get(:ticket => { :author => 'Me' })
      assigns[:ticket].should == @ticket
    end

    it 'should automatically assign the last used name and email of the user' do
      controller.should_receive(:cached_user_attribute).with(:name, 'Anonymous').and_return('Me')
      controller.should_receive(:cached_user_attribute).with(:email).and_return('me@home')
      @ticket.should_receive(:author=).with('Me')
      @ticket.should_receive(:email=).with('me@home')
      do_get
    end

    it 'should successfully render the template' do
      do_get
      response.should be_success
      response.should render_template(:new)
    end

  end



  describe "handling POST /tickets" do    

    before do      
      @ticket = stub_model(Ticket, :protected_attributes= => nil)
      @tickets_proxy.stub!(:new).and_return @ticket
      @ticket_params = { 'author' => 'Me', 'email' => 'me@home', 'summary' => 'Summary', 'content' => 'Content' }
    end

    def do_post(params = {})
      post :create, params.merge(:project_id => @project.to_param, :ticket => @ticket_params) 
    end

    it 'should initialize a new ticket' do
      @tickets_proxy.should_receive(:new).with(@ticket_params).and_return @ticket
      do_post
      assigns[:ticket].should == @ticket
    end

    it 'should assign ticket\'s attributes' do
      @ticket.should_receive :protected_attributes=
      do_post
    end

    it 'should store author\'s IP' do
      @ticket.should_receive :author_host=
      do_post
    end

    describe 'if \'watch ticket\' was selected' do

      it 'should subscribe the user to the ticket' do
        @ticket.should_receive(:toggle_subscriber).with(@user)
        do_post(:watch_ticket => '1')
      end

    end

    describe 'if \'watch ticket\' was NOT selected' do

      it 'should NOT subscribe the user to the ticket' do
        @ticket.should_not_receive(:toggle_subscriber)
        do_post
      end

    end

    describe "with successful save" do

      def do_post(options = {})
        @ticket.should_receive(:save).and_return true
        super
      end

      it "should store user attributes in the cookies" do
        do_post
        cookies['retrospectiva__c'].should_not be_blank
      end

      it "should redirect to the ticket" do
        do_post
        response.should redirect_to(project_ticket_path(@project, @ticket))
      end

      describe "XML request" do
        
        before do
          controller.stub!(:authenticate_with_http_basic).and_return(@user)
        end
        
        
        def do_post
          super :format => 'xml'
        end
        
        it 'should authenticate the user' do
          controller.should_receive(:authenticate_with_http_basic).and_return(@user)          
          do_post
        end

        it 'should be successful' do
          do_post
          response.should be_success
        end
        
        it 'should return the record with the correct location' do
          do_post
          response.headers['Location'].should == project_ticket_url(@project, @ticket)
          response.content_type.should == "application/xml"
          response.body.should have_tag('ticket')
        end
        
      end

    end

    describe "with failed save" do

      def do_post
        @ticket.should_receive(:save).and_return false
        super
      end

      it "should display the 'new' template" do
        do_post
        response.should be_success
        response.should render_template(:new)
      end

    end

  end




  describe "handling PUT /ticket/1" do

    before do
      @ticket = stub_model(Ticket)
      @ticket_change = stub_model(TicketChange, :save => true)
      @tickets_proxy.stub!(:find_by_id).and_return @ticket
      @changes_proxy = @ticket.stub_association!(:changes, :new => @ticket_change)
      @change_params = { 'author' => 'Me', 'email' => 'me@home', 'content' => 'Content' }
      controller.stub!(:cached_user_attribute)
      Ticket.stub!(:default_includes).and_return([:DEFAULTS])
    end

    def do_put(params = {})
      put :update, params.merge(:project_id => @project.to_param, :ticket_change => @change_params, :id => '1')
    end

    it 'should find the ticket' do
      @tickets_proxy.should_receive(:find_by_id).with('1',
        :order=>"ticket_changes.created_at",
        :include=>[:DEFAULTS]
      ).and_return @ticket
      do_put
      assigns[:ticket].should == @ticket
    end

    it 'should initialize and assign new ticket-change' do
      @changes_proxy.should_receive(:new).with().and_return @ticket_change
      do_put
      assigns[:ticket_change].should == @ticket_change
    end

    it 'should assign ticket change content' do
      @ticket_change.should_receive(:attributes=).with(@change_params).and_return(@change_params)
      do_put
    end

    describe "with successful save" do

      before do
        controller.stub! :cache_user_attributes!
      end

      def do_put(*args)
        @ticket_change.should_receive(:save).and_return true
        super
      end

      it "should store user attributes in the cookies" do
        controller.should_receive :cache_user_attributes!
        do_put
      end

      it "should redirect to the ticket" do
        do_put
        response.should redirect_to(project_ticket_path(@project, @ticket, :anchor => "ch#{@ticket_change.id}"))
      end

      describe 'if \'watch ticket\' was selected' do

        it 'should subscribe the user to the ticket' do
          @ticket.should_receive(:toggle_subscriber).with(@user)
          do_put(:watch_ticket => '1')
        end

      end

      describe 'if \'watch ticket\' was NOT selected' do

        it 'should NOT subscribe the user to the ticket' do
          @ticket.should_not_receive(:toggle_subscriber)
          do_put
        end

      end

    end

    describe "with failed save" do

      def do_put
        @ticket_change.should_receive(:save).and_return false
        super
      end

      it "should display the 'show' template" do
        do_put
        response.should be_success
        response.should render_template(:show)
      end

    end

  end





  describe "handling GET /tickets/1/download/2/file.txt" do

    before do
      @ticket = mock_model(Ticket, :id => 1)
      @attachment = mock_model Attachment,
        :file_name => 'file.txt',
        :attachable => @ticket,
        :plain? => true,
        :inline? => true,
        :redirect? => false,
        :readable? => true,
        :send_arguments => ['path', {}]
      Attachment.stub!(:find).and_return(@attachment)
      controller.stub!(:send_file)
      controller.stub!(:render)
    end

    def do_get
      get :download, :project_id => @project.to_param, :ticket_id => '1', :id => '2', :file_name => 'file.txt'
    end

    it 'should find and assign the attachment' do
      Attachment.should_receive(:find).with('2', :include => :attachable).and_return(@attachment)
      do_get
      assigns[:attachment].should == @attachment
    end

    describe 'if attachment is readable and the related ticket matches' do

      it 'should send the attachment' do
        @attachment.should_receive(:readable?).and_return(true)
        @attachment.should_receive(:attachable).twice.and_return(@ticket)
        controller.should_receive(:send_file).with('path', {})
        do_get
      end

    end

    describe 'if attachment is readable and the related ticket-change matches' do
      before do
        @ticket_change = mock_model(TicketChange, :ticket_id => 1)
      end

      it 'should send the attachment' do
        @attachment.should_receive(:attachable).twice.and_return(@ticket_change)
        controller.should_receive(:send_file)
        do_get
      end

    end

    describe 'if attachment is not readable' do

      it 'should raise an error' do
        @attachment.should_receive(:readable?).and_return(false)
        lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)
      end

    end

    describe 'if attachment does not match the ticket' do

      it 'should raise an error' do
        @ticket.should_receive(:id).and_return(999)
        lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)
      end

    end

    describe 'if attachment does not match the ticket-change' do
      before do
        @ticket_change = mock_model(TicketChange, :ticket_id => 999)
      end

      it 'should raise an error' do
        @attachment.should_receive(:attachable).twice.and_return(@ticket_change)
        lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)
      end

    end

    describe 'if attachment does neither belong to a ticket nor to a ticket-change' do
      before do
        @milestone = mock_model(Milestone)
      end

      it 'should raise an error' do
        @attachment.should_receive(:attachable).and_return(@milestone)
        lambda { do_get }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end

  end



  describe "handling XHR-PUT /tickets/1/modify_summary" do

    before do
      @ticket = mock_model(Ticket, :update_attribute_without_timestamps => true, :summary => 'NEW', :summary_was => 'WAS')
      @tickets_proxy.stub!(:find).and_return(@ticket)
      @user.stub!(:permitted?).and_return(true)
      controller.stub!(:failed_authorization)
    end

    def do_xhr_put
      xhr :put, :modify_summary, :project_id => @project.to_param, :id => '1', :value => 'NEW'
    end

    it 'should reject non-XHR requests' do
      put :modify_summary, :project_id => @project.to_param, :id => '1', :value => 'NEW'
      response.code.should == '400'
    end

    it 'should find the ticket' do
      @tickets_proxy.should_receive(:find).with('1').and_return(@ticket)
      do_xhr_put
      assigns[:ticket].should == @ticket
    end

    it 'should validate if the ticket is modifiable' do
      @user.should_receive(:permitted?).with(:tickets, :modify, @ticket).and_return(true)
      controller.should_not_receive(:failed_authorization!)
      do_xhr_put
    end

    it 'should refuse authorization if the ticket is not modifiable' do
      @user.should_receive(:permitted?).with(:tickets, :modify, @ticket).and_return(false)
      controller.should_receive(:failed_authorization!)
      do_xhr_put
    end

    describe 'if update is successful' do

      it 'should render the new content' do
        @ticket.should_receive(:update_attribute_without_timestamps).with(:summary, 'NEW').and_return(true)
        do_xhr_put
        response.should be_success
        assigns[:summary].should == 'NEW'
      end

    end

    describe 'if update is not successful' do

      it 'should render the old content' do
        @ticket.should_receive(:update_attribute_without_timestamps).with(:summary, 'NEW').and_return(false)
        do_xhr_put
        response.should be_success
        assigns[:summary].should == 'WAS'
      end

    end

  end



  describe "handling XHR-PUT /tickets/1/modify_content" do

    before do
      @ticket = mock_model(Ticket, :update_attribute_without_timestamps => true, :content => 'NEW', :content_was => 'WAS')
      @tickets_proxy.stub!(:find).and_return(@ticket)
      @user.stub!(:permitted?).and_return(true)
      controller.stub!(:failed_authorization!)
    end

    def do_xhr_put
      xhr :put, :modify_content, :project_id => @project.to_param, :id => '1', :value => 'NEW'
    end

    it 'should reject non-XHR requests' do
      put :modify_content, :project_id => @project.to_param, :id => '1', :value => 'NEW'
      response.code.should == '400'
    end

    it 'should find the ticket' do
      @tickets_proxy.should_receive(:find).with('1').and_return(@ticket)
      do_xhr_put
      assigns[:ticket].should == @ticket
    end

    it 'should validate if the ticket is modifiable' do
      @user.should_receive(:permitted?).with(:tickets, :modify, @ticket).and_return(true)
      controller.should_not_receive(:failed_authorization!)
      do_xhr_put
    end

    it 'should refuse authorization if the ticket is not modifiable' do
      @user.should_receive(:permitted?).with(:tickets, :modify, @ticket).and_return(false)
      controller.should_receive(:failed_authorization!)
      do_xhr_put
    end

    describe 'if update is successful' do

      it 'should render the new content' do
        @ticket.should_receive(:update_attribute_without_timestamps).with(:content, 'NEW').and_return(true)
        do_xhr_put
        response.should be_success
        assigns[:content].should == 'NEW'
      end

    end

    describe 'if update is not successful' do

      it 'should render the old content' do
        @ticket.should_receive(:update_attribute_without_timestamps).with(:content, 'NEW').and_return(false)
        do_xhr_put
        response.should be_success
        assigns[:content].should == 'WAS'
      end

    end

  end


  describe "handling XHR-PUT /tickets/1/modify_change_content" do

    before do
      @ticket_change = mock_model(TicketChange, :update_attribute => true, :content => 'NEW', :content_was => 'WAS')
      @changes_proxy.stub!(:find).and_return(@ticket_change)
      @user.stub!(:permitted?).and_return(true)
      controller.stub!(:failed_authorization!)
    end

    def do_xhr_put
      xhr :put, :modify_change_content, :project_id => @project.to_param, :id => '1', :value => 'NEW'
    end

    it 'should reject non-XHR requests' do
      put :modify_change_content, :project_id => @project.to_param, :id => '1', :value => 'NEW'
      response.code.should == '400'
    end

    it 'should find the ticket change' do
      @changes_proxy.should_receive(:find).with('1').and_return(@ticket_change)
      do_xhr_put
      assigns[:ticket_change].should == @ticket_change
    end

    it 'should validate if the ticket is modifiable' do
      @user.should_receive(:permitted?).with(:tickets, :modify, @ticket_change).and_return(true)
      controller.should_not_receive(:failed_authorization!)
      do_xhr_put
    end

    it 'should refuse authorization if the ticket is not modifiable' do
      @user.should_receive(:permitted?).with(:tickets, :modify, @ticket_change).and_return(false)
      controller.should_receive(:failed_authorization!)
      do_xhr_put
    end

    describe 'if update is successful' do

      it 'should render the new content' do
        @ticket_change.should_receive(:update_attribute).with(:content, 'NEW').and_return(true)
        do_xhr_put
        response.should be_success
        assigns[:content].should == 'NEW'
      end

    end

    describe 'if update is not successful' do

      it 'should render the old content' do
        @ticket_change.should_receive(:update_attribute).with(:content, 'NEW').and_return(false)
        do_xhr_put
        response.should be_success
        assigns[:content].should == 'WAS'
      end

    end

  end

  describe "handling DELETE /tickets/1 (destroy)" do

    before do
      @ticket = mock_model(Ticket)
      @tickets_proxy.stub!(:find_by_id).and_return(@ticket)
      @ticket.stub!(:destroy).and_return(true)
      Ticket.stub!(:default_includes).and_return([:DEFAULTS])
    end

    def do_delete
      delete :destroy, :project_id => @project.to_param, :id => '1'
    end

    it 'should find and assign the ticket' do
      @tickets_proxy.should_receive(:find_by_id).with('1', :order => 'ticket_changes.created_at', :include => [:DEFAULTS]).and_return(@ticket)
      do_delete
      assigns[:ticket].should == @ticket
    end

    it 'should destroy the ticket' do
      @ticket.should_receive(:destroy).and_return(true)
      do_delete
    end

    it 'should redirect to tickets list' do
      do_delete
      response.should redirect_to(project_tickets_path(@project))
    end

  end


  describe "handling DELETE /tickets/1/2 (destroy_change)" do

    before do
      @ts = 3.weeks.ago
      @ticket = mock_model(Ticket, :created_at => @ts, :changes => [], :update_timestamp => nil)
      @ticket_change = mock_model(TicketChange, :ticket => @ticket, :destroy => true)
      @changes_proxy.stub!(:find).and_return(@ticket_change)
    end

    def do_delete
      delete :destroy_change, :project_id => @project.to_param, :ticket_id => '1', :id => '2'
    end

    it 'should find and assign the ticket change and the ticket' do
      @changes_proxy.should_receive(:find).with('2', :include=>:ticket).and_return(@ticket_change)
      do_delete
      assigns[:ticket_change].should == @ticket_change
      assigns[:ticket].should == @ticket
    end

    it 'should destroy the ticket change' do
      @ticket_change.should_receive(:destroy).and_return(true)
      do_delete
    end

    it 'should update the ticket\'s timestamp' do
      @ticket.should_receive(:update_timestamp).with(@ts).and_return(true)
      do_delete
    end

    it 'should redirect to ticket' do
      do_delete
      response.should redirect_to(project_ticket_path(@project, @ticket))
    end

  end


  describe "handling POST /tickets/1/toggle_subscription" do

    before do
      @ticket = mock_model(Ticket)
      @tickets_proxy.stub!(:find_by_id).and_return(@ticket)
      @ticket.stub!(:toggle_subscriber).and_return(true)
      Ticket.stub!(:default_includes).and_return([:DEFAULTS])
    end

    it 'should reject non-POST requests (404)' do
      lambda {
        get :destroy_change, :project_id => @project.to_param, :id => '1'
      }.should raise_error(ActionController::RoutingError)
    end

    def do_post
      post :toggle_subscription, :project_id => @project.to_param, :id => '1'
    end

    it 'should find and assign the ticket' do
      @tickets_proxy.should_receive(:find_by_id).with('1', :order => 'ticket_changes.created_at', :include => [:DEFAULTS]).and_return(@ticket)
      do_post
      assigns[:ticket].should == @ticket
    end

    it 'should toggle the subscription' do
      @ticket.should_receive(:toggle_subscriber).with(@user)
      do_post
    end

    it 'should redirect the to ticket' do
      do_post
      response.should redirect_to(project_ticket_path(@project, @ticket))
    end

  end


  describe "handling POST /tickets/users" do
    
    def do_post(options = {})
      post :users, options.merge(:project_id => '1')
    end
    
    describe 'if user assignment via text field is disabled' do
      
      before do
        RetroCM[:ticketing][:user_assignment].stub!(:[]).and_return('drop-down')        
      end
      
      it 'should raise an error (404)' do
        RetroCM[:ticketing][:user_assignment].should_receive(:[]).with(:field_type).and_return('drop-down')        
        lambda { do_post }.should raise_error(ActionController::UnknownAction)
      end
      
    end

    describe 'if user assignment via text field is enabled' do
      
      before do
        @tom, @jerry = mock_model(User, :name => 'Tom'), mock_model(User, :name => 'Jerry')
        @users_proxy = @project.stub_association!(:users, :with_permission => [@tom, @jerry])
        RetroCM[:ticketing][:user_assignment].stub!(:[]).and_return('text-field')        
      end
      
      it 'should find and assign matching users' do
        @project.should_receive(:users).and_return(@users_proxy)
        @users_proxy.should_receive(:with_permission).with(:tickets, :update).and_return([@tom, @jerry])
        do_post(:assigned_user => 'to')
        assigns[:users].should == [@tom]
      end
      
    end
    
    
  end


end
