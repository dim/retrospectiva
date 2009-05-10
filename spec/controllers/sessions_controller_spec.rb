require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SessionsController do
  before do
    @user = mock_model(User, :time_zone => 'London')
    User.stub!(:current).and_return(@user)
  end


  describe 'GET /new (/login)' do    

    describe 'if not logged-in' do

      before do
        @user.should_receive(:public?).and_return(true)        
      end
      
      def do_get
        get :new
      end
      
      it_should_successfully_render_template('new')
    end

    describe 'if logged-in' do
      before do
        @user.should_receive(:public?).and_return(false)
      end
      
      def do_get
        get :new        
      end
      
      it_should_successfully_render_template('logged_in')
    end    
  end


  describe 'POST /create' do

    describe 'with invalid user-params' do

      def do_post
        post :create, :user => 'abcd'
      end

      it 'should redirect-to the login screen' do
        do_post
        response.should redirect_to(login_path)
      end

      it 'should reset the the session' do        
        session[:user_id] = 1
        do_post
        session[:user_id].should be_nil        
      end

    end


    describe 'with correct user-credentials' do

      before do
        User.stub!(:authenticate).and_return(@user)
      end

      def do_post
        post :create, :user => {:username => 'myaccount', :password => 'passW0rd'}        
      end

      it 'should authenticate user' do    
        User.should_receive(:authenticate).with('username' => "myaccount", 'password' => "passW0rd").and_return(@user)      
        do_post
      end

      it 'should confirm success' do    
        do_post
        flash[:notice].should_not be_blank
      end

      it 'should set session' do
        session[:user_id] = 1
        do_post
        session[:user_id].should == @user.id        
      end

      describe 'if back-to location is set' do
        it 'should redirect to it' do
          session[:back_to] = '/projects'
          do_post
          response.should redirect_to(projects_path)
        end
      end

      describe 'if no back-to location is set' do
        it 'should redirect to home' do
          do_post
          response.should redirect_to(root_path)
        end
      end

    end

    
    describe 'with incorrect user-credentials' do
      before do
        User.should_receive(:authenticate).and_return(nil)
      end

      def do_post
        post :create, :user => {:username => 'invalid', :password => 'wrong'}
      end
      
      it 'should confirm wrong credentials' do
        do_post
        flash[:error].should_not be_blank
      end

      it 'should redirect to login' do
        do_post
        response.should be_redirect
        response.should redirect_to(login_path)
      end    
    end
  end


  describe 'GET /destroy (/logout)' do    
    fixtures :users

    def do_get
      get :destroy      
    end
    
    it 'should reset session' do
      controller.should_receive(:reset_session)
      do_get
    end
    
    it_should_successfully_render_template('destroy')
  end


  describe 'GET /secure' do  
    it 'should not be allowed' do
      RetroCM[:general][:user_management].stub!(:[]).with(:secure_auth).and_return(true)
      get :secure
      response.code.to_i.should == 400      
    end
  end


  describe 'XHR-GET /secure' do  
    it 'should not be allowed' do
      RetroCM[:general][:user_management].stub!(:[]).with(:secure_auth).and_return(true)
      xhr :get, :secure
      response.code.to_i.should == 400      
    end
  end


  describe 'XHR-POST /secure' do    
    before do
      RetroCM[:general][:user_management].stub!(:[]).with(:secure_auth).and_return(true)      
    end

    describe 'without a username parameter' do  
      it 'should not be allowed' do
        xhr :post, :secure
        response.code.to_i.should == 400      
      end
    end

    describe 'when secure authentication is disabled' do  
      it 'should return nothing' do
        RetroCM[:general][:user_management].stub!(:[]).with(:secure_auth).and_return(false)
        xhr :post, :secure, :username => 'myaccount'
        response.should be_success
        response.body.should be_blank
      end
    end

    describe 'with a valid username parameter' do  
      before do
        User.should_receive(:find_by_username).with('myaccount').and_return(@user)
        @user.should_receive(:salt).and_return('QwErTyU')
        xhr :post, :secure, :username => 'myaccount'
      end

      it 'should return the user salt' do
        response.should be_success
        response.body.should == 'QwErTyU'
      end
    end

    describe 'with a invalid username parameter' do  
      before do
        User.should_receive(:find_by_username).with('invalid').and_return(nil)
        xhr :post, :secure, :username => 'invalid'
      end

      it 'should return nothing' do
        response.should be_success
        response.body.should be_blank
      end
    end
  end

end
