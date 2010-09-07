require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do

  describe 'permission checks' do
    
    before do
      @user = stub_current_user! :public? => true, :permitted => true    
    end

    it 'should forward checks currently logged-in user' do
      @user.should_receive(:permitted?).with(:tickets, :view).and_return(true)
      controller.send :permitted?, :tickets, :view
    end

    it 'should be protected' do
      lambda { controller.permitted?(:tickets, :view) }.
        should raise_error(NoMethodError, /protected method/)
    end

  end

  describe 'rescueing failed requests' do
    
    def template_path(code)
      "#{RAILS_ROOT}/app/views/rescue/#{code}.html.erb"      
    end
    
    def do_rescue
      controller.send :rescue_action_in_public, nil      
    end
    
    before do
      controller.stub!(:render)
      ExceptionNotifier.stub!(:deliver_exception_notification)
      ExceptionNotifier.stub!(:exception_recipients).and_return(['[DUMMY]'])
    end
    
    
    describe 'if a page was not found (404)' do

      before do
        controller.stub!(:response_code_for_rescue).and_return(:not_found)
      end
              
      it 'should render the 404 error page ' do
        controller.should_receive(:render).with(:file => template_path(404), :layout => 'application', :status => '404 Not Found') 
        do_rescue        
      end
    
      it 'should NOT send a notification email' do
        ExceptionNotifier.should_not_receive(:deliver_exception_notification)
        do_rescue
      end

    end

    describe 'if the user tried to POST content without a valid token (422)' do

      before do
        controller.stub!(:response_code_for_rescue).and_return(:unprocessable_entity)
      end
              
      it 'should render the 422 error page ' do
        controller.should_receive(:render).with(:file => template_path(422), :layout => 'application', :status => '422 Unprocessable Entity') 
        do_rescue        
      end

      it 'should NOT send a notification email' do
        ExceptionNotifier.should_not_receive(:deliver_exception_notification)
        do_rescue
      end
    
    end

    describe 'if user tries a not-implemented request (not GET/POST/PUT/DELETE)' do

      before do
        controller.stub!(:response_code_for_rescue).and_return(:not_implemented)
      end

      it 'should respond with a HEAD message' do
        controller.should_receive(:head).with("501 Not Implemented") 
        do_rescue        
      end
              
      it 'should NOT send a notification email' do
        ExceptionNotifier.should_not_receive(:deliver_exception_notification)
        do_rescue
      end
    
    end

    
    describe 'if a bug is causing an actual application error' do

      before do
        controller.stub!(:response_code_for_rescue).and_return(:internal_server_error)
      end

      it 'should render the 500 error page ' do
        controller.should_receive(:render).with(:file => template_path(500), :layout => 'application', :status => '500 Internal Server Error') 
        do_rescue        
      end

      it 'should send a notification email' do
        ExceptionNotifier.should_receive(:deliver_exception_notification)
        do_rescue
      end
      
      it 'should NOT send a notification email if no recipients were defined' do
        ExceptionNotifier.should_receive(:exception_recipients).and_return([])
        ExceptionNotifier.should_not_receive(:deliver_exception_notification)
        do_rescue
      end
    
    end


    describe 'if user has no permission (403)' do

      before do
        controller.stub!(:response_code_for_rescue).and_return(:forbidden)
      end
              
      it 'should render the 403 error page ' do
        controller.should_receive(:render).with(:file => template_path(403), :layout => 'application', :status => '403 Forbidden') 
        do_rescue        
      end

      it 'should NOT send a notification email' do
        ExceptionNotifier.should_not_receive(:deliver_exception_notification)
        do_rescue
      end
    
    end
  end
end

describe 'Format rendering and fallback' do
  controller_name :milestones
  include Spec::TypicalMilestonesControllerSetup 

  before do
    rescue_action_in_public!     
  end
  
  it 'should render HTML if no specific format requested' do
    get :index, :project_id => @project.to_param
    response.should be_success
    response.content_type.should == 'text/html' 
  end

  it 'should render the format if no specific format requested and expicitely allowed' do
    get :index, :project_id => @project.to_param, :format => 'rss'
    response.should be_success
    response.content_type.should == 'application/rss+xml' 
  end

  it 'should return 406 Not Acceptable if requested format is not part of respond-to' do
    get :index, :project_id => @project.to_param, :format => 'text'
    response.code.should == '406'
  end
  
  it 'should return 406 Not Acceptable if requested format is invalid (no respond-to specified)' do
    get :index, :project_id => @project.to_param, :id => '1', :format => 'text'
    response.code.should == '406'
  end

  it 'should ignore format parameter if empty' do
    get :index, :project_id => @project.to_param, :format => ''
    response.should be_success
    response.content_type.should == 'text/html' 
  end

end


describe 'RSS access via private key' do
  controller_name :milestones
  include Spec::TypicalMilestonesControllerSetup

  before do
    @user.stub!(:permitted?).and_return(false) 
  end
  
  describe 'if key is valid but non-RSS content is requested' do
    
    it 'should not try to authorize the user via key' do
      User.should_not_receive(:find_by_private_key)
      get :index, :project_id => 'retro', :private => '[PKEY]'
    end

    it 'should redirect to login as usually' do
      get :index, :project_id => 'retro', :private => '[PKEY]'
      response.should redirect_to(login_path)
    end
  end
  
  describe 'if RSS content is requested' do
 
    it 'should fallback to HTTP-Basic if user cannot be authenticated via private key' do
      bypass_rescue
      get :index, :project_id => 'retro', :format => 'rss'
      response.code.should == '401'
    end

    describe 'if a valid private key is submitted' do
      
      before do
        User.stub!(:find_by_private_key).and_return(@user)
        @user.stub!(:permitted?).and_return(true)
      end
      
      def do_get(options = {})
        get :index, { :project_id => 'retro', :format => 'rss', :private => '[PKEY]' }.merge(options)
      end
      
      it 'should find the user by the key' do
        User.should_receive(:find_by_private_key).with('[PKEY]').and_return(@user)
        do_get
      end
      
      it 'should permit access' do
        do_get
        response.should be_success
        response.body.should include('rss version="2.0"')
        end
 
        it 'should reset the session afterwards' do
        do_get
        session[:user_id].should be_nil
      end
      
    end
  
  end
end


describe 'Caching user attributes' do
  controller_name :tickets

  before do      
    Status.stub!(:default).and_return(mock_model(Status))
    Priority.stub!(:default).and_return(mock_model(Priority))
    @ticket = stub_model(Ticket)
    @tickets = []
    @tickets.stub!(:find).and_return(@ticket)
    @tickets.stub!(:new).and_return(@ticket)
    @tickets.stub!(:count)
    @tickets.stub!(:maximum)

    @project = permit_access_with_current_project! :name => 'Any', :tickets => @tickets
    @user = stub_current_user! :public? => false, :name => 'Agent', :email => 'agent@mail.com' 
  end

  describe 'storing' do
    before do
      @ticket.stub!(:save).and_return(true)
    end      
    
    def do_post
      post :create, :project_id => @project.to_param, :ticket => { :author => 'Agent', :email => 'agent@mail.com' } 
    end
    
    it 'should behave correctly' do
      cookies['retrospectiva__c'].should be_nil
      do_post
      cookies['retrospectiva__c'].should  == "--- \nname: Agent\nemail: agent@mail.com\n"
    end    

  end

  describe 'retrieving' do
    
    before do
      cookies['retrospectiva__c'] = "--- \nname: Author\nemail: something@mail.com\n" 
    end

    def do_get
      get :new, :project_id => @project.to_param
    end
    
    it 'should unescape the values correctly' do
      controller.send(:cookie_cache).should == { 'name' => 'Author', 'email' => 'something@mail.com' }
    end

    describe 'if user is public' do
      before do
        @user.stub!(:public?).and_return(true)
      end

      it 'should assign the cached values' do
        do_get
        @ticket.author.should == 'Author'
        @ticket.email.should == 'something@mail.com'
      end            

      describe 'if nothing is in cache' do
        before do
          cookies['retrospectiva__c'] = nil
        end

        it 'should assign fall-back values' do
          do_get
          @ticket.author.should == 'Anonymous'
          @ticket.email.should == ''
        end            
      end    

    end    

    describe 'if user is NOT public' do
      it 'should assign the user values' do
        do_get
        @ticket.author.should == 'Agent'
        @ticket.email.should == 'agent@mail.com'
      end            
    end    
    
  end
end




describe 'Back-to path storage' do
  controller_name :search

  before do
    permit_access_with_current_project!
    controller.stub!(:load_channels).and_return([])
    @user = stub_current_user! :name => 'Doesnt Matter' 
  end       
  
  def do_get
    get :index, :project_id => 'one'
  end
  
  describe 'if user is logged-in' do
    before do      
      @user.stub!(:public?).and_return(false)
    end
    
    it 'should NOT store the request path' do
      do_get
      session[:back_to].should be_nil
    end
    
  end

  describe 'if user is not logged-in' do
    before do
      @user.stub!(:public?).and_return(true)
    end
    
    it 'should store the request path' do
      do_get
      session[:back_to].should == '/projects/one/search'
    end
    
    describe 'and if relative URL root is set' do
      
      before do
        ActionController::Base.stub!(:relative_url_root).and_return('/dev')
      end
      
      it 'should store the request path correctly' do
        do_get
        session[:back_to].should == '/dev/projects/one/search'
      end
      
    end
    
  end  
end

describe "Authorization" do
  controller_name :milestones
  include Spec::TypicalMilestonesControllerSetup
    
  def do_get(options = {})
    get :index, options.reverse_merge(:project_id => 'one')
  end
  
  describe 'if a user is already logged in' do
    
    before do
      @user.stub!(:public?).and_return(false)
    end
    
    describe 'and is permitted to see page' do
      before do
        controller.class.stub!(:authorize?).and_return(true)          
      end
      
      it 'should display the page (for HTML)' do
        do_get
        response.should be_success
      end

      it 'should display the page (for XML/RSS)' do
        do_get(:format => 'xml')
        response.should be_success
        do_get(:format => 'rss')
        response.should be_success
      end

    end    

    describe 'and is not permitted to see page' do
      before do
        rescue_action_in_public!
        controller.stub!(:consider_all_requests_local).and_return(false)
        controller.class.stub!(:authorize?).and_return(false)          
      end
      
      it 'should return a 403 page (for HTML)' do
        do_get
        response.code.should == '403'
        response.should render_template(RAILS_ROOT + '/app/views/rescue/403.html.erb')
      end

      it 'should return a 403 head (for XML/RSS)' do
        do_get(:format => 'xml')
        response.code.should == '403'
        response.body.should be_blank
      end

      it 'should return a 403 head (for RSS)' do
        do_get(:format => 'rss')
        response.code.should == '403'
        response.body.should be_blank
      end

    end    

  end

  describe 'if a user is NOT logged in' do
    
    before do
      @user.stub!(:public?).and_return(true)
    end
          
    describe 'and is permitted to see page' do
      
      before do
        controller.class.stub!(:authorize?).and_return(true)          
      end
      
      it 'should display the page (for HTML)' do
        do_get
        response.should be_success
      end

      it 'should display the page (for XML/RSS)' do
        do_get(:format => 'xml')
        response.should be_success
        do_get(:format => 'rss')
        response.should be_success
      end

    end    

    describe 'and is not permitted to see page' do
      before do
        controller.class.stub!(:authorize?).and_return(false)          
      end
              
      it 'should redirect to login page (for HTML)' do
        do_get
        response.should redirect_to(login_path)
      end

      it 'should request HTTP Basic credentials (for XML/RSS)' do
        do_get(:format => 'xml')
        response.code.should == '401'
        do_get(:format => 'rss')
        response.code.should == '401'
      end
      
    end    

  end
end
