require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  fixtures :users, :groups_users, :groups, :groups_projects, :projects

  describe 'on class level' do
    it "should be able to find the public user" do
      User.public_user.should == users(:Public)
    end

    it "should not cache public user" do
      User.public_user.projects.should == [projects(:retro)]
      groups(:Default).update_attribute(:access_to_all_projects, true)
      User.public_user.projects.should == projects(:closed, :retro, :sub)
    end
  
    describe 'mass-assignement' do
      it 'should only be allowed for [name, plain_password & confirmation]' do
        User.attr_accessible.sort.should == 
          [:name, :plain_password, :plain_password_confirmation, :time_zone].map(&:to_s).sort
      end
    end
  end
  

  describe 'in general' do
    fixtures :changesets, :tickets, :ticket_changes
    
    it "should have and belong to many groups" do
      users(:agent).should have_and_belong_to_many(:groups)
      users(:agent).groups.should have(1).record
    end

    it "should identify if the user is the last administrator" do
      users(:agent).should_not be_last_admin  
      users(:admin).should be_last_admin  
      users(:admin).admin = false
      users(:admin).should be_last_admin  
    end

    it "should have many changesets" do
      users(:agent).should have_many(:changesets)
      users(:agent).changesets.should have(2).records
    end

    it "should have many login tokens" do
      users(:agent).should have_many(:login_tokens)
    end

    it "should have many assigned tickets" do
      users(:agent).should have_many(:assigned_tickets)
      users(:agent).assigned_tickets.should have(1).record
    end

    it "should have many contributed tickets" do
      users(:agent).should have_many(:tickets)
      users(:agent).tickets.should have(1).record
    end

    it "should have many contributed ticket changes" do
      users(:agent).should have_many(:ticket_changes)
      users(:agent).ticket_changes.should have(1).record
    end

    it "should have many projects" do
      users(:agent).should have(1).projects
    end

  end


  describe 'on save' do
    before { @user = users(:agent) } 

    it "should validate presence of username" do
      @user.should validate_presence_of(:username)
    end

    it "should validate length of username (3-40 characters)" do
      @user.should validate_length_of(:username, :within => 3..40)
    end

    it "should validate uniqueness of username" do
      @user.should validate_uniqueness_of(:username)
    end

    it "should validate correct format of username" do
      @user.username = 'User Name'
      @user.should have(1).error_on(:username)
      @user.username = "User\tName"
      @user.should have(1).error_on(:username)
      @user.username = 'Username '
      @user.should have(1).error_on(:username)
      @user.username = ' Username'
      @user.should have(1).error_on(:username)
      @user.username = '@home'
      @user.should have(:no).error_on(:username)
      @user.username = 'Username123'
      @user.should have(:no).error_on(:username)
      @user.username = 'Username.123!'
      @user.should have(:no).error_on(:username)
    end

    it "should validate confirmation of plain password" do      
      @user.plain_password = 'abcdefgh'
      @user.should have(1).error_on(:plain_password)

      @user.plain_password = 'abcdefgh'
      @user.plain_password_confirmation = 'hgfedcba'
      @user.should have(1).error_on(:plain_password)

      @user.plain_password = 'abcdefgh'
      @user.plain_password_confirmation = 'abcdefgh'
      @user.should have(:no).error_on(:plain_password)
    end
    
    it "should validate presence of name" do
      @user.should validate_presence_of(:name)
    end

    it "should validate presence of email" do
      @user.should validate_presence_of(:email)
    end

    it "should validate uniqueness of email" do
      @user.should validate_uniqueness_of(:email)
    end

    it "should validate valid time-zone" do
      @user.time_zone = 'Invalid'
      @user.should have(1).error_on(:time_zone)
    end

    it 'should normalize assigned time-zone' do
      @user.time_zone = 'Brasilia'
      @user.should have(:no).errors_on(:time_zone)
      @user.time_zone.should == 'Brasilia'

      @user.time_zone = 'America/Sao_Paulo'
      @user.should have(:no).errors_on(:time_zone)
      @user.time_zone.should == 'Brasilia'
    end
    
    it 'should skip time-zone normalization if time-zone is not correct' do
      @user.time_zone = 'America/Brasilia'
      @user.should have(1).error_on(:time_zone)
      @user.time_zone.should == 'America/Brasilia'      
    end

    it "should validate email address (if set)" do
      @user.should have(:no).errors_on(:email)
      @user.email = nil
      @user.should have(1).errors_on(:email)
      @user.email = 'not - valid'
      @user.should have(1).errors_on(:email)
    end

    it "should validate uniqueness of SCM name" do
      @user.should validate_uniqueness_of(:scm_name)
    end

    it "should allow SCM name to be blank" do
      @user.scm_name = ''
      @user.should have(:no).errors_on(:scm_name)
    end
    
    describe 'if plain password is blank' do
      before do
        @user.save
      end
      
      it "should not change the hashed password" do
        @user.password.should == 'b742714644f63a57f3bfe7dbe782451f0fe982b4'
      end
    end

    describe 'if plain password is not blank and matches the confirmation' do
      before do
        @user.plain_password = @user.plain_password_confirmation = 'P@ssw0rd'
        @user.save
      end
      
      it "should reset the hashed password" do
        @user.password.should == '53e4c33ad6929847483991799f37b12a0388e5bc'
      end

      it "should empty the plain password + confirmation" do
        @user.plain_password.should be_blank
        @user.plain_password_confirmation.should be_blank
      end
    end
        
    describe 'if user is an admin' do
      before do
        @user = users(:admin)
      end
      
      it "should automatically drop all associated groups" do
        @user.groups << groups(:Default)
        @user.groups.should have(1).record
        @user.valid?
        @user.groups.should have(:no).records
      end

      it "should allow 'downgrade' if user is the last admin" do
        @user.should be_last_admin
        @user.admin = false
        @user.should have(1).errors_on(:admin)
      end
    end
    
    describe 'if user is Public' do
      before do
        User.stub!(:current).and_return(users(:admin))
        @user = users(:Public)
      end

      it "should NOT validate presence of name" do
        @user.should_not validate_presence_of(:name)
      end
  
      it "should NOT validate presence of email" do
        @user.should_not validate_presence_of(:email)
      end      

      it "should NOT validate uniqueness of email" do
        @user.should_not validate_uniqueness_of(:email)
      end

      it 'should not allow changes to the Public user record' do
        @user.name = 'Some name'  
        @user.should have(1).error_on(:base)
      end

      it 'should rollback changes if Public user record modification was attempted' do
        @user.name = 'Some name'
        @user.should have(1).error_on(:base)
        @user.name.should == 'Anonymous'
      end

      it 'should not allow the Public user to become admin' do
        @user.admin = true
        @user.should have(1).errors_on(:admin)
      end

      it 'should not allow the Public user to become inactive' do
        @user.active = false
        @user.should have(1).errors_on(:active)
      end          
    end
  
    describe 'if user is the currently logged-in user' do
      before do
        @user = users(:admin)
        @user.stub!(:last_admin?).and_return(false)
        User.stub!(:current).and_return(@user)
      end
      
      it "should not allow admin 'downgrade'" do
        @user.admin = false
        @user.should have(1).errors_on(:admin)
      end

      it "should not allow to become inactive" do
        @user.active = false
        @user.should have(1).errors_on(:active)
      end
    end    
  end


  describe 'on create' do
    before do
      @user = User.new(:name => 'New One', :plain_password => 'password', :plain_password_confirmation => 'password')
      @user.username = 'new_one'
      @user.email = 'new@one.com'
    end

    it "should validate presence of plain password" do
      @user.should validate_presence_of(:plain_password)
    end

    it "should validate length of plain password (6-40 characters)" do
      @user.should validate_length_of(:plain_password, :within => 6..40)
    end

    it "should validate length of plain password (6-40 characters)" do
      @user.should validate_length_of(:plain_password, :within => 6..40)
    end
    
    it "should validate confirmation of plain password" do      
      @user.plain_password = 'abcdefgh'
      @user.should have(1).error_on(:plain_password)

      @user.plain_password = 'abcdefgh'
      @user.plain_password_confirmation = 'hgfedcba'
      @user.should have(1).error_on(:plain_password)

      @user.plain_password = 'abcdefgh'
      @user.plain_password_confirmation = 'abcdefgh'
      @user.should have(:no).error_on(:plain_password)
    end
    
    describe 'if retrospectiva is set-up to automatically assign new users to certain groups' do
      before do
        RetroCM[:general][:user_management].should_receive(:[]).
          with(:activation).
          and_return('')
        RetroCM[:general][:user_management].should_receive(:[]).
          with(:assign_to_groups).
          and_return([groups(:other).id])
        @user.save.should be_true
      end
      
      it 'should automatically assign the specified groups' do
        @user.groups.should have(2).records
        @user.groups.should include(groups(:other))
      end
    end

    describe 'if activation is to be done by administrators (:activation => \'admin\')' do
      before do
        RetroCM[:general][:user_management].should_receive(:[]).
          with(:activation).
          and_return('admin')
        RetroCM[:general][:user_management].should_receive(:[]).
          with(:assign_to_groups).
          and_return([])
        @user.save.should be_true
      end
      
      it 'should make the new record inactive' do
        @user.should_not be_active
      end
    end

    describe 'if activation is to be done via email-confirmation (:activation => \'email\')' do
      before do
        RetroCM[:general][:user_management].should_receive(:[]).
          with(:activation).
          and_return('email')
        RetroCM[:general][:user_management].should_receive(:[]).
          with(:assign_to_groups).
          and_return([])
        @user.save.should be_true
      end
      
      it 'should make the new record inactive' do
        @user.should_not be_active
      end

      it 'should create an activation code' do
        @user.activation_code.should_not be_blank
      end
    end

  end


  describe 'on destroy' do

    describe 'if user is public' do
      before do
        User.stub!(:current).and_return(users(:admin))
      end

      it 'should prevent the user from being destroyed' do
        users(:Public).destroy.should be(false)
      end
      it 'should add an error message' do
        users(:Public).destroy.should be(false)
        users(:Public).errors.on(:base).should match(/cannot be deleted/)
      end      
    end

    describe 'if user is the last admin' do
      it 'should prevent the user from being destroyed' do
        users(:admin).destroy.should be(false)
      end
      it 'should add an error message' do
        users(:admin).destroy.should be(false)
        users(:admin).errors.on(:base).should match(/cannot delete/i)
      end      
    end

    describe 'if user is the currently logged-in user' do
      before do
        User.stub!(:current).and_return(users(:agent))
      end
      
      it 'should prevent the user from being destroyed' do
        users(:agent).destroy.should be(false)
      end
      it 'should add an error message' do
        users(:agent).destroy.should be(false)
        users(:agent).errors.on(:base).should match(/cannot delete/i)
      end      
    end    
  end


  describe 'identification' do
    
    it 'should never identify Public' do
      User.identify('Public').should be_nil
    end

    it 'should identify active users by username' do
      User.identify(users(:agent).username).should == users(:agent)
    end

    it 'should identify active users by email' do
      User.identify(users(:agent).email).should == users(:agent)
    end

    it 'should not identify inactive users by username' do
      User.identify(users(:inactive).username).should be_nil
    end

    it 'should not identify inactive users by email' do
      User.identify(users(:inactive).email).should be_nil
    end
    
  end

  
  describe 'authentication' do
    
    describe 'in general' do
      it 'should never authenticate Public' do
        User.authenticate(:username => 'Public').should be_nil
      end
    end

    describe 'in secure mode' do
      before do
        @user = users(:agent)
        @token = 'QwErTyUiOp'
        @hash = Digest::SHA1.hexdigest("#{@token}:#{@user.password}")        
        User.stub!(:secure_auth?).and_return(true)
        SecureToken.stub!(:spend).and_return(@token)
      end
      
      it 'should authenticate if username, tan and hash are given correctly calculated' do
        User.authenticate(:username => @user.username, :tan => @token, :hash => @hash).should == @user
      end

      it 'should not authenticate if username doe notusername match hash' do
        User.authenticate(:username => @user.username, :tan => @token, :hash => 'wrong').should be_nil
      end      

      it 'should not authenticate if tan has expired' do
        SecureToken.stub!(:spend).and_return(nil)
        User.authenticate(:username => @user.username, :tan => @token, :hash => @hash).should be_nil
      end      
    end

    describe 'in standard mode' do
      before do
        User.stub!(:secure_auth?).and_return(false)
        @user = users(:agent)
      end
      
      it 'should authenticate if username and password match' do
        User.authenticate(:username => @user.username, :password => 'password').should == @user
      end

      it 'should NOT authenticate if username and password do not match' do
        User.authenticate(:username => @user.username, :password => 'wrong').should be_nil
      end      
    end
    
  end



  describe 'access check' do
    before do
      @user = User.new
      ChangesetsController.stub!(:authorize?).and_return(true)
    end
    
    describe 'if a path option hash is passed' do
      it 'should generate a path-string first' do
        options = {:project_id => 'one', :controller => 'changesets'}
        ActionController::Routing::Routes.should_receive(:generate).
          with(options).and_return('/projects/one/changesets')
        @user.has_access?(options)
      end
    end

    it 'should convert the path to an option array' do
      ActionController::Routing::Routes.should_receive(:recognize_path).
        with('/changesets', :method => :get).and_return(:controller => 'changesets')
      @user.has_access?('/changesets')
    end

    describe 'if path contains a project-ID' do

      it 'should extract the ID and try to find the project' do
        Project.should_receive(:find_by_short_name).with('retrospectiva').and_return(projects(:retro))
        @user.has_access?('/projects/retrospectiva/changesets')
      end
      
    end

    it 'should extract the controller and action name and \'ask\' the controller for permission' do
      options = {:controller => 'changesets', :action => 'new'}
      ActionController::Routing::Routes.should_receive(:recognize_path).
        with('/changesets/new', :method => :get).and_return(options)
      ChangesetsController.should_receive(:authorize?).with('new', options, @user, nil).and_return(true)
      @user.has_access?('/changesets/new').should be(true)      
    end    
  end


  describe 'permission check' do
    before do
      Project.stub!(:current).and_return(projects(:retro))
    end
    
    def permissions_for(user_key, project_key)
      users(user_key).send(:project_permissions, projects(project_key))
    end
      
    it 'should differ from project to project' do
      permissions_for(:agent, :retro).should == groups(:Default).permissions
      permissions_for(:agent, :sub).should == {}
      permissions_for(:double_agent, :retro).should ==  { 
        "code"=>["browse"], 
        "changesets"=>["view"], 
        "content"=>["search"], 
        "milestones"=>["create", "view"],
        "tickets"=>["create", "modify", "update", "view", "watch"] }
      permissions_for(:double_agent, :sub).should == groups(:all_projects).permissions
    end

    it 'should merge permissions from multiple groups' do
      permissions_for(:double_agent, :retro)['milestones'].sort.should == ['create', 'view']
    end

    describe 'if no project is given' do
      it 'should take the current project' do
        users(:agent).should_receive(:project_permission?).with(projects(:retro), :tickets, :view).and_return(false)
        users(:agent).permitted?(:tickets, :view).should be(false)        
      end
    end

    describe 'if no project is given and no current project is specified' do
      before do
        Project.stub!(:current).and_return(nil)
      end
      
      it 'should always return false' do
        users(:agent).should_not_receive(:project_permission?)
        users(:agent).permitted?(:tickets, :view).should be(false)        
      end      
    end

    describe 'if a project is given as an option' do
      it 'should take specified project' do        
        users(:agent).should_receive(:project_permission?).with(projects(:sub), :tickets, :view).and_return(false)
        users(:agent).permitted?(:tickets, :view, :project => projects(:sub)).should be(false)
      end
    end

    describe 'if user is permitted (permission is granted on project level)' do

      before do
        users(:agent).stub!(:project_permission?).and_return(true)
        @permission = mock_model(RetroAM::Permission, :custom? => false)
        RetroAM.permission_map.stub!(:find).and_return(@permission)
      end
    
      it 'should return false if permission is not defined in the system' do
        RetroAM.permission_map.should_receive(:find).with(:tickets, :spam).and_return(nil)
        users(:agent).permitted?(:tickets, :spam).should be(false)
      end

      it 'should return true if the permission is defined in the system' do
        RetroAM.permission_map.should_receive(:find).with(:tickets, :view).and_return(@permission)
        users(:agent).permitted?(:tickets, :view).should be(true)
      end


      describe 'if the permission has no callback' do
        
        it 'should NOT evaluate permission' do
          @permission.should_receive(:custom?).and_return(false)
          @permission.should_not_receive(:evaluate)
          users(:agent).permitted?(:tickets, :view).should be(true)
        end
        
      end

      describe 'if the permission has a callback' do
        
        it 'should evaluate permission' do
          @permission.should_receive(:custom?).and_return(true)
          @permission.should_receive(:evaluate).with(projects(:retro), users(:agent), true, 'A', 123).and_return(true)
          users(:agent).permitted?(:tickets, :view, 'A', 123).should be(true)
        end        

      end
    end
    
    
    describe 'in reality' do      
      fixtures :tickets, :ticket_changes
      
      it 'should allow users to access the specified project-specific resources' do
        users(:agent).permitted?(:tickets, :view).should be(true)
        users(:agent).permitted?(:milestones, :view).should be(true)
        users(:agent).permitted?(:milestones, :update).should be(false)
        users(:agent).permitted?(:tickets, :view, :project => projects(:sub)).should be(false)

        users(:double_agent).permitted?(:tickets, :view).should be(true)
        users(:double_agent).permitted?(:milestones, :view).should be(true)
        users(:double_agent).permitted?(:milestones, :update).should be(false)
        users(:double_agent).permitted?(:tickets, :view, :project => projects(:sub)).should be(true)
        users(:double_agent).permitted?(:tickets, :update, :project => projects(:sub)).should be(false)        
      end

      it 'should always deny permission to non-active users' do
        users(:inactive).permitted?(:tickets, :view).should be(false)
        users(:inactive).permitted?(:content, :search).should be(false)
      end

      it 'should always grant persmission to admins' do
        users(:admin).permitted?(:tickets, :view).should be(true)
        users(:admin).permitted?(:tickets, :update).should be(true)
        users(:admin).permitted?(:tickets, :modify).should be(true)
        users(:admin).permitted?(:tickets, :view, :project => projects(:sub)).should be(true)
        users(:admin).permitted?(:tickets, :update, :project => projects(:sub)).should be(true)
        users(:admin).permitted?(:tickets, :modify, :project => projects(:sub)).should be(true)
      end

      describe 'permissions with callbacks' do
        
        it 'should not allow Public to watch tickets (even if permission was accidetntally assigned)' do
          users(:Public).send(:project_permission?, projects(:retro), :tickets, :watch).should be(true)
          users(:Public).permitted?(:tickets, :watch).should be(false)
        end
      
        describe 'modification of tickets/ticket-changes' do
          
          it 'should be granted for admin users' do
            users(:admin).permitted?(:tickets, :modify).should be(true)        
          end

          it 'should be granted for users with global permission' do
            users(:double_agent).send(:project_permission?, projects(:retro), :tickets, :modify).should be(true)
            users(:double_agent).permitted?(:tickets, :modify).should be(true)
          end

          describe 'for users without global permission' do

            describe 'if \'author-modification\' is ON' do
              
              before do 
                RetroCM[:ticketing][:author_modifiable].stub!(:[]).with(:tickets).and_return(true)                
                RetroCM[:ticketing][:author_modifiable].stub!(:[]).with(:ticket_changes).and_return(true)
              end

              it 'should check for global permission' do
                users(:agent).send(:project_permission?, projects(:retro), :tickets, :modify).should be(false)
              end
              
              it 'should grant permission to modify their own tickets' do
                users(:agent).permitted?(:tickets, :modify, tickets(:agents_ticket)).should be(true)
              end
  
              it 'should grant permission to modify their own ticket changes' do
                users(:agent).permitted?(:tickets, :modify, ticket_changes(:agents_ticket_update)).should be(true)
              end

              it 'should REFUSE permission to modify other\'s tickets' do
                users(:agent).permitted?(:tickets, :modify, tickets(:another_open)).should be(false)
              end              

              it 'should REFUSE permission to modify other\'s ticket changes' do
                users(:agent).permitted?(:tickets, :modify, ticket_changes(:another_open_update)).should be(false)
              end              
              
            end
            
            describe 'if \'author-modification\' is OFF' do
              
              before do 
                RetroCM[:ticketing][:author_modifiable].stub!(:[]).with(:tickets).and_return(false)                
                RetroCM[:ticketing][:author_modifiable].stub!(:[]).with(:ticket_changes).and_return(false)
              end
      
              it 'should REFUSE permission to modify even their own tickets' do
                users(:agent).permitted?(:tickets, :modify, tickets(:agents_ticket)).should be(false)
              end

              it 'should REFUSE permission to modify even their own ticket changes' do
                users(:agent).permitted?(:tickets, :modify, ticket_changes(:agents_ticket_update)).should be(false)
              end

            end
          end

        end

      end      
    end    
  end

end
