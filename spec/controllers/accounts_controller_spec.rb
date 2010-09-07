require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AccountsController do

  before do
    @user = stub_current_user!
    @project = permit_access_with_current_project!
    @new = mock_model(User)
    User.stub!(:new).and_return(@new)
  end

  class << self

    def it_should_redirect_if_user_is_public(method = :do_get)
      it 'should redirect to login if user IS public' do
        @user.stub!(:public?).and_return(true)
        send(method)
        response.should redirect_to(login_path)
      end
    end

    def it_should_redirect_if_user_is_not_public(method = :do_get)
      it 'should redirect to home if user is NOT public' do
        @user.stub!(:public?).and_return(false)
        send(method)
        response.should redirect_to(root_path)
      end
    end


    def it_should_verify_that_account_management_is_enabled(method = :do_get)
      it 'should verify that account management is enabled' do
        controller.should_receive(:configured?).with(:account_management).and_return false
        lambda { send(method) }.should raise_error(ActionController::UnknownAction)
      end
    end

    def it_should_verify_that_registration_is_enabled(method = :do_get)
      it 'should verify that registration is enabled' do
        controller.stub!(:configured?).and_return(true)
        controller.should_receive(:configured?).with(:self_registration).and_return false
        lambda { send(method) }.should raise_error(ActionController::UnknownAction)
      end
    end

    def it_should_verify_that_activation_by_email_is_enabled(method = :do_get)
      it 'should verify that activation is enabled' do
        controller.stub!(:configured?).and_return(true)
        controller.should_receive(:configured?).with(:activation, 'email').and_return(false)
        lambda { send(method) }.should raise_error(ActionController::UnknownAction)
      end
    end

  end

  describe "handling GET /account" do

    before do
      @user.stub!(:public?).and_return(false)
    end

    def do_get(params = {})
      get :show, params
    end

    it_should_verify_that_account_management_is_enabled
    it_should_redirect_if_user_is_public

    it 'should assign the current user for the view' do
      do_get
      assigns[:user].should == @user
    end

    it_should_successfully_render_template('show')

    describe "if user is public but a login-ticket was passed" do
      
      before do
        @agent = mock_model(User)
        @token = mock_model(LoginToken, :user => @agent, :destroy => true)  
        
        LoginToken.stub!(:find_by_id_and_value).and_return(@token)
        
        User.stub!(:current=)
        @user.stub!(:public?).and_return(true)
      end
  
      def do_get
        super(:lt => 'LT-123-KEY') 
      end
  
      it_should_verify_that_account_management_is_enabled
  
      it 'should try to authenticate the user' do
        LoginToken.should_receive(:find_by_id_and_value).with(123, 'KEY').and_return(@token)
        @token.should_receive(:user).with().and_return(@agent)
        User.should_receive(:current=).with(@agent)
        do_get
        session[:user_id].should == @agent.id
      end
    end

  end

  before do
    @project = permit_access_with_current_project!
    @new = mock_model(User)
    User.stub!(:new).and_return(@new)
  end


  describe "handling PUT /account" do

    before do
      @user.stub!(:public?).and_return(false)
      @user.stub!(:attributes=)
      @user.stub!(:save).and_return(true)
    end

    def do_put(options = {})
      put :update, options.reverse_merge(:user =>  {:name => 'New Name' })
    end

    it_should_verify_that_account_management_is_enabled(:do_put)
    it_should_redirect_if_user_is_public(:do_put)

    it 'should assign the current user for the view' do
      do_put
      assigns[:user].should == @user
    end

    it 'should assign the changed attributes' do
      @user.should_receive(:attributes=).with('name' => 'New Name')
      @user.should_not_receive(:reset_private_key)
      do_put
    end

    describe "if 'reset private key' was selected" do

      it 'should reset the private key' do
        @user.should_receive(:reset_private_key)
        do_put(:reset_private_key => '1')
      end

    end

    describe "with successful save" do

      it 'should redirect to account overview' do
        @user.should_receive(:save).and_return(true)
        do_put
        response.should redirect_to(account_path)
      end

    end

    describe "with failed save" do

      it 'should render the form again' do
        @user.should_receive(:save).and_return(false)
        do_put
        response.should render_template('show')
      end

    end

  end


  describe 'handling GET /accounts/new' do

    before do
      @user.stub!(:public?).and_return(true)
      RetroCM[:general][:user_management].stub!(:[]).and_return(true)
      RetroCM[:general][:user_management].stub!(:[]).with(:self_registration).and_return(true)
    end

    def do_get
      get :new
    end

    it_should_verify_that_account_management_is_enabled
    it_should_verify_that_registration_is_enabled
    it_should_redirect_if_user_is_not_public

    it 'should initialize and assign a new user' do
      User.should_receive(:new).and_return(@new)
      do_get
      assigns[:user].should == @new
    end

    it_should_successfully_render_template('new')

  end

  describe 'handling POST /accounts' do

    before do
      @new.stub!(:attributes=)
      @new.stub!(:email=)
      @new.stub!(:username=)
      @new.stub!(:save).and_return(true)
      @user.stub!(:public?).and_return(true)
      @user_attrs = { 'username' => 'me', 'email' => 'me@work', 'name' => 'Me' }
      controller.stub!(:purge_expired_accounts)
      RetroCM[:general][:user_management].stub!(:[]).and_return(true)
      RetroCM[:general][:user_management].stub!(:[]).with(:self_registration).and_return(true)
    end

    def do_post
      post :create, :user => @user_attrs
    end

    it_should_verify_that_account_management_is_enabled(:do_post)
    it_should_verify_that_registration_is_enabled(:do_post)
    it_should_redirect_if_user_is_not_public(:do_post)

    it 'should purge expired user accounts' do
      controller.should_receive(:purge_expired_accounts)
      do_post
    end

    it 'should initialize and assign a new user' do
      User.should_receive(:new).and_return(@new)
      do_post
      assigns[:user].should == @new
    end

    it 'should assign the values to the user' do
      @new.should_receive(:attributes=).with(@user_attrs)
      @new.should_receive(:username=).with('me')
      @new.should_receive(:email=).with('me@work')
      do_post
    end

    describe "with successful save" do

      it 'should proceed with successful-registration' do
        @new.should_receive(:save).and_return(true)
        do_post
      end

    end

    describe "with failed save" do

      it 'should proceed with failed-registration' do
        @new.should_receive(:save).and_return(false)
        do_post
        response.should be_success
        response.should render_template(:new)
      end

    end

  end


  describe 'handling GET /account/activate' do

    before do
      @user.stub!(:public?).and_return(true)
      RetroCM[:general][:user_management].stub!(:[]).and_return(true)
      RetroCM[:general][:user_management].stub!(:[]).with(:activation).and_return('email')
      controller.stub!(:purge_expired_accounts)
    end

    def do_get(options = {})
      get :activate, options
    end

    it_should_verify_that_account_management_is_enabled
    it_should_verify_that_activation_by_email_is_enabled
    it_should_redirect_if_user_is_not_public

    it 'should purge expired user accounts' do
      controller.should_receive(:purge_expired_accounts)
      do_get
    end

    describe "if username and code parameters are present" do

      before do
        @pending = mock_model(User)
        User.stub!(:find_by_username_and_activation_code).and_return(@pending)
        controller.stub!(:successful_activation)
      end


      def do_get
        super(:username => 'me', :code => '1234')
      end

      it 'should find the pending user account' do
        User.should_receive(:find_by_username_and_activation_code).with('me', '1234').and_return(@pending)
        do_get
      end

      it 'should proceed with successful activation if user was found' do
        controller.should_receive(:successful_activation).with(@pending)
        do_get
      end

    end

    describe "if login and code parameters are NOT present" do

      it_should_successfully_render_template('activate')

    end

  end


  describe 'handling GET /account/forgot_password' do

    before do
      @user.stub!(:public?).and_return(true)
    end
    
    def do_get
      get :forgot_password
    end
    
    it_should_verify_that_account_management_is_enabled
    it_should_redirect_if_user_is_not_public

    it 'should display the forgot-password form' do
      do_get
      response.should be_success
      response.should render_template(:forgot_password)
    end
    
  end


  describe 'handling POST /account/forgot_password' do
    
    before do
      @agent = mock_model(User)
      User.stub!(:identify).and_return(@agent)
      @user.stub!(:public?).and_return(true)
      Notifications.stub!(:queue_password_reset_instructions)
    end
    
    def do_post(value = nil)
      post :forgot_password, :username_or_email => value 
    end
    
    it_should_verify_that_account_management_is_enabled(:do_post)
    it_should_redirect_if_user_is_not_public(:do_post)

    it 'should identify the user' do
      User.should_receive(:identify).with('[VALUE]').and_return(@agent)
      do_post('[VALUE]')
    end

    describe 'if user is found' do

      it 'should send a password-recovery email to the user' do
        Notifications.should_receive(:queue_password_reset_instructions).with(@agent)
        do_post
      end

      it 'should redirect to the login page' do
        do_post
        response.should redirect_to(login_path)
      end
      
    end

    describe 'if user is NOT found' do

      before do
        User.stub!(:identify).and_return(nil)
      end

      it 'should display the form again' do
        do_post
        response.should be_success
        response.should render_template(:forgot_password)
      end
      
    end
    
  end


  describe 'successful registration process' do
    before do
      @user.stub!(:public?).and_return(true)
      @new.stub!(:attributes=)
      @new.stub!(:email=)
      @new.stub!(:username=)
      @new.stub!(:save).and_return(true)
      RetroCM[:general][:user_management].stub!(:[]).with(:activation).and_return('auto')      
      controller.stub!(:configured?).and_return(true)
      controller.stub!(:purge_expired_accounts)
    end

    def do_call
      post :create, :user => {}
    end

    it 'should initate the process' do
      controller.should_receive(:successful_registration)
      controller.should_receive(:render)
      do_call
    end

    describe 'if activation is not required' do

      it 'should redirect to login' do
        do_call
        response.should redirect_to(login_path)
      end

      it 'should notify the user' do
        do_call
        flash[:notice].should have(1).record
      end

    end

    describe 'if activation requires admin' do

      before do
        RetroCM[:general][:user_management].stub!(:[]).with(:activation).and_return('admin')
      end

      it 'should redirect to login' do
        do_call
        response.should redirect_to(login_path)
      end

      it 'should notify the user' do
        do_call
        flash[:notice].should have(2).records
        flash[:notice].last.should match(/not allowed to login until .+ activated by .+ administrator/)
      end

    end

    describe 'if activation requires email validation' do

      before do
        RetroCM[:general][:user_management].stub!(:[]).with(:activation).and_return('email')
        RetroCM[:general][:user_management].stub!(:[]).with(:expiration).and_return(48)
        Notifications.stub!(:queue_account_validation)
        controller.stub!(:activate_account_path)        
      end

      it 'should notify the user' do
        RetroCM[:general][:user_management].should_receive(:[]).with(:expiration).and_return(48)
        do_call
        flash[:notice].should have(3).records
        flash[:notice].last.should match(/email .+ was sent to you/)
      end

      it 'should redirect to activation' do
        do_call
        response.should redirect_to(account_activate_path)
      end

      it 'should send-out a validation email' do
        Notifications.should_receive(:queue_account_validation).with(@new)
        do_call
      end
    end

  end


  describe 'failed registration process' do
    
    before do
      controller.stub!(:render)      
    end

    it 'should re-render the new-account form' do
      controller.should_receive(:render).with(:action => 'new')
      controller.send(:failed_registration)
    end

    it 'should set the error-flash if messages were passed' do
      controller.send(:failed_registration, 'Error message')
      flash[:error].should == 'Error message'
    end

  end


  describe 'successful activation process' do

    before do
      controller.stub!(:activation_enabled?).and_return(true)
      controller.stub!(:user_is_public?).and_return(true)
      @pending = mock_model(User, :activation_code= => nil, :active= => nil, :save => true)
      User.stub!(:find_by_username_and_activation_code).and_return(@pending)
    end
    
    def do_get(options = {})
      get :activate, :username => 'me', :code => '1234'
    end

    it 'should reset the activation code' do
      @pending.should_receive(:activation_code=).with(nil)
      do_get
    end

    it 'should set the user to \'active\'' do
      @pending.should_receive(:active=).with(true)
      do_get
    end

    it 'should should save the user' do
      @pending.should_receive(:save).and_return(true)
      do_get
    end

    it 'should should save the user' do
      @pending.should_receive(:save).and_return(true)
      do_get
    end
    
    it 'should should redirect to login' do
      do_get
      response.should redirect_to(login_path)
    end
    
  end

  describe 'purge expired accounts' do
    before do
      @time = 3.hours.ago
      @three = mock('Three', :hours => mock('Hours', :ago => @time))
      controller.stub!(:config).and_return(:expiration => @three)      
      User.stub!(:destroy_all)
    end

    it 'should destroy all expired users' do
      User.should_receive(:destroy_all).with(['activation_code IS NOT NULL AND active = ? AND created_at < ?', false, @time])
      controller.send :purge_expired_accounts
    end
    
  end


end
