require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do

  describe 'permission checks' do
    
    before do
      @user = mock_current_user! :public? => true, :permitted => true    
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

  describe 'retrieving cached user attributes' do
    before do
      @user = mock_current_user! :public? => true, :name => 'Jerry'
      controller.stub!(:cookies).and_return(cookies)
    end
    
    def do_call
      controller.send :cached_user_attribute, :name, 'Anonymous'        
    end
    
    describe 'if user is public' do
            
      it 'should try to read the cookie to retrieve the last used value' do
        controller.send(:cookies).should_receive(:[]).with("__cu_name").and_return('Tom')
        do_call.should == 'Tom'
      end
      
      it 'should use the fallback value if no value is stored in the cookie' do
        do_call.should == 'Anonymous'
      end
      
    end
    
    describe 'if user is NOT public' do

      before do
        @user.stub!(:public?).and_return(false) 
      end
      
      it 'should not check the cookie' do
        cookies.should_not_receive(:[])
        do_call
      end
      
      it 'should use the name of the logged-in user' do
        do_call.should == 'Jerry'
      end
      
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
    end
    
    
    describe 'if a page was not found (404)' do

      before do
        controller.stub!(:response_code_for_rescue).and_return(:not_found)
      end
              
      it 'should render the 404 error page ' do
        controller.should_receive(:render).with(:file => template_path(404), :layout => 'application.html.erb', :status => '404 Not Found') 
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
        controller.should_receive(:render).with(:file => template_path(422), :layout => 'application.html.erb', :status => '422 Unprocessable Entity') 
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
        controller.should_receive(:render).with(:file => template_path(500), :layout => 'application.html.erb', :status => '500 Internal Server Error') 
        do_rescue        
      end

      it 'should send a notification email' do
        ExceptionNotifier.should_receive(:deliver_exception_notification)
        do_rescue
      end
    
    end


    describe 'if user has no permission (403)' do

      before do
        controller.stub!(:response_code_for_rescue).and_return(:forbidden)
        controller.stub!(:login_path).and_return('/path/to/login') 
        controller.stub!(:redirect_to) 
      end
              
      it 'should redirect ro login-page ' do
        controller.should_receive(:login_path).and_return('/path/to/login') 
        controller.should_receive(:redirect_to).with('/path/to/login') 
        do_rescue
      end
    
      it 'should not double-render' do
        controller.should_not_receive(:render) 
        do_rescue
      end
    
    end
  end
end

describe ChangesetsController do
  describe 'default render patch (auto-respond-to HTML)' do

    before do
      @project = permit_access_with_current_project! :name => 'Any', :to_param => '1'        
      @changesets = [stub_model(Changeset, :to_param => '1', :project => @project)]
      @project.stub!(:changesets).and_return(@changesets)
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

    it 'should return 406 Not Acceptable if requested format is not part of expicitely allowed ones' do
      get :index, :project_id => @project.to_param, :format => 'xml'
      response.code.should == '406'
    end
    
    it 'should return 406 Not Acceptable if requested format is not HTML and no formats were specified' do
      @changesets.should_receive(:find_by_revision!).and_return(@changesets.first)
      @changesets.should_receive(:find).twice.and_return(nil)
      get :show, :project_id => @project.to_param, :id => '1', :format => 'xml'
      response.code.should == '406'
    end

  end
end



describe ChangesetsController do
  describe 'default render patch (auto-respond-to HTML)' do

    before do
      @project = permit_access_with_current_project! :name => 'Any', :to_param => '1'        
      @changesets = [stub_model(Changeset, :to_param => '1', :project => @project)]
      @project.stub!(:changesets).and_return(@changesets)
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

    it 'should return 406 Not Acceptable if requested format is not part of expicitely allowed ones' do
      get :index, :project_id => @project.to_param, :format => 'xml'
      response.code.should == '406'
    end
    
    it 'should return 406 Not Acceptable if requested format is not HTML and no formats were specified' do
      @changesets.should_receive(:find_by_revision!).and_return(@changesets.first)
      @changesets.should_receive(:find).twice.and_return(nil)
      get :show, :project_id => @project.to_param, :id => '1', :format => 'xml'
      response.code.should == '406'
    end

  end
end