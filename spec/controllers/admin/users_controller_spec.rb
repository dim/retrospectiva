require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::UsersController do
  it_should_behave_like EveryAdminAreaController
  
  before do
    permit_access!
    @users = [mock_model(User), mock_model(User)]
    Group.stub!(:find).and_return([])
  end

  describe "handling GET /admin/users" do

    before(:each) do
      User.stub!(:find).and_return(@users)
    end

    def do_get
      get :index      
    end
  
    it_should_successfully_render_template('index')

    it "should find user records" do
      User.should_receive(:find).
        with(:all,
        :conditions => nil,
        :order => 'CASE users.id WHEN 0 THEN 0 ELSE 1 END, users.admin DESC, users.name',
        :include => [:groups],
        :offset => 0, :limit => User.per_page).
        and_return(@users)
      do_get
    end

    it "should assign the found users for the view" do
      do_get
      assigns[:users].should == @users.paginate
    end

  end
  

  describe "handling GET /admin/users/search" do

    before(:each) do
      User.stub!(:find).and_return(@users)
    end

    def do_get
      get :search, :term => 'name'      
    end
    
    it_should_successfully_render_template('search')

    it "should find users" do
      User.should_receive(:find).and_return(@users)
      do_get
    end

    it "should assign the found users for the view" do
      do_get
      assigns[:users].should == @users.paginate
    end

  end


  describe "handling GET /admin/users/new" do

    before(:each) do
      @user = mock_model(User)
      User.stub!(:new).and_return(@user)
      Group.stub!(:find).and_return([])
    end
    
    def do_get
      get :new      
    end
  
    it_should_successfully_render_template('new')
  
    it "should create an new user" do
      User.should_receive(:new).and_return(@user)
      do_get
    end
  
    it "should not save the new user" do
      @user.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new user for the view" do
      do_get
      assigns[:user].should equal(@user)
    end

    it "should pre-load the group records" do
      Group.should_receive(:find).and_return([])
      do_get
      assigns[:groups].should == []
    end
    
  end


  describe "handling GET /admin/users/1/edit" do

    before(:each) do
      @user = mock_model(User, :public? => false)
      User.stub!(:find).and_return(@user)
    end
  
    def do_get
      get :edit, :id => "1"      
    end
  
    it "should find the user requested" do
      User.should_receive(:find).with('1').and_return(@user)
      do_get
    end
  
    it "should assign the found user for the view" do
      do_get
      assigns[:user].should equal(@user)
    end

    it_should_successfully_render_template('edit')

    it "should pre-load the group records" do
      Group.should_receive(:find).
        with(:all,  :conditions => ['id <> ?', 0], :order => 'name').
        and_return([])
      do_get
      assigns[:groups].should == []
    end

  end


  describe "handling POST /admin/users" do

    before(:each) do
      @user = mock_model(User, :to_param => "1")
      User.stub!(:new).and_return(@user)
      Group.stub!(:find).and_return([])
    end
    
    describe "with successful save" do
  
      def do_post
        @user.should_receive(:attributes=).with({}, false)
        @user.should_receive(:save).and_return(true)
        post :create, :user => {}
      end
  
      it "should create a new user" do
        User.should_receive(:new).with({}).and_return(@user)
        do_post
      end

      it "should not pre-load the group records" do
        Group.should_not_receive(:find)
        do_post
      end

      it "should redirect to the user list" do
        do_post
        response.should redirect_to(admin_users_path)
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @user.should_receive(:attributes=).with({}, false)
        @user.should_receive(:save).and_return(false)
        post :create, :user => {}
      end
  
      it_should_successfully_render_template('new', :do_post)

      it "should pre-load the group records" do
        Group.should_receive(:find).
          with(:all,  :conditions => ['id <> ?', 0], :order => 'name').
          and_return([])
        do_post
        assigns[:groups].should == []
      end
      
    end
  end


  describe "handling PUT /admin/users/1" do

    before(:each) do
      @user = mock_model(User, :to_param => "1", :public? => false)
      @user.instance_eval do
        def active?; @active; end
        def active=(value); @active = value; end
        def attributes=(values, guard = true); @active = (values && values['active'].to_i > 0); end
      end
      @user.active = true
      
      User.stub!(:find).and_return(@user)
      Group.stub!(:find).and_return([])
    end

    describe "with successful update" do

      def do_put(options = {})
        @user.should_receive(:save).and_return(true)
        put :update, options.merge(:id => "1")
      end

      it "should find the user requested" do
        User.should_receive(:find).with("1").and_return(@user)
        do_put
      end

      it "should update the found user" do
        @user.should_receive(:attributes=).with(nil, false)
        do_put
        assigns(:user).should equal(@user)
      end

      it "should not pre-load the group records" do
        Group.should_not_receive(:find)
        do_put
      end

      describe 'on post-process' do

        before do
          controller.stub!(:admin_user_activation?).and_return(false)        
        end
        
        it 'should redirect to the user list' do
          do_put
          response.should redirect_to(admin_users_path)
        end

        describe 'if users can only be activated by admins' do          

          describe 'a user is activated' do
            before do
              controller.stub!(:admin_user_activation?).and_return(true)
              @user.active = false
            end
 
            describe 'if the send-notification parameter was given' do
              it 'should send out a activation notification to the user' do
                Notifications.should_receive(:queue_account_activation_note).with(@user)
                do_put(:user => {:active => '1'}, :send_notification => '1')
              end             
            end

            describe 'if the send-notification parameter was NOT given' do
              it 'should NOT send out a activation notification to the user' do
                Notifications.should_not_receive(:queue_account_activation_note)
                do_put(:user => {:active => '1'})
              end             
            end
          end

        end        
      end      
    end
    
    
    describe "with failed update" do

      def do_put
        @user.should_receive(:attributes=).with(nil, false)
        @user.should_receive(:save).and_return(false)
        put :update, :id => "1"
      end

      it_should_successfully_render_template('edit', :do_put)

      it "should pre-load the group records" do
        Group.should_receive(:find).
          with(:all,  :conditions => ['id <> ?', 0], :order => 'name').
          and_return([])
        do_put
        assigns[:groups].should == []
      end

      it "should not run succesfull update post-process" do
        do_put
        controller.should_not_receive(:successful_update)
      end
      
    end
  end


  describe "handling DELETE /users/1" do

    before(:each) do
      @user = stub_model(User, :to_param => "1", :destroy => true)
      User.stub!(:find).and_return(@user)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find and destroy the user requested" do
      @user.should_receive(:destroy).and_return(true)
      do_delete
    end
  
    it "should redirect to the users list" do
      do_delete
      response.should redirect_to(admin_users_path)
    end
  end


end
