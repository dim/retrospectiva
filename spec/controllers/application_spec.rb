require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationController do


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

  describe 'rescuing failed requests' do
    
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
    
    end
    
  end

end
