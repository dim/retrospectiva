require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Notifications do

  before do
    ActionMailer::Base.deliveries.clear
  end
    

  def fixture(name)
    File.read(RAILS_ROOT + "/spec/fixtures/notifications/#{name}")    
  end

  describe 'reloading confguration' do
    
    before do 
      @settings = {
        :address => mock('Setting::Address', :name => 'address', :value => 'mail.mydomain.com'),
        :port => mock('Setting::Port', :name => 'port', :value => 225),
        :domain => mock('Setting::Domain', :name => 'domain', :value => 'mydomain.com'),
        :authentication => mock('Setting::AuthType', :name => 'authentication', :value => 'plain'),
        :user_name => mock('Setting::User', :name => 'user_name', :value => 'me'),
        :password => mock('Setting::Pass', :name => 'password', :value => 'secret'),
        :enable_starttls_auto => mock('Setting::AutoTLS', :name => 'enable_starttls_auto', :value => true)
      }
    end
    
    
    describe 'in general' do      

      before do 
        RetroCM[:email][:smtp].stub!(:settings).and_return @settings.values
      end
      
      it 'should correctly assign settings' do
        ActionMailer::Base.should_receive(:smtp_settings=).with(
          :enable_starttls_auto => true,                
          :address => 'mail.mydomain.com', 
          :port => 225, 
          :domain => 'mydomain.com', 
          :authentication => :plain, 
          :user_name => 'me', 
          :password => 'secret')
        Notifications.reload_settings
      end      

    end    
    
    
    describe 'if authentication is set to \'none\'' do

      before do 
        @settings[:authentication].stub!(:value).and_return 'none'
        RetroCM[:email][:smtp].stub!(:settings).and_return @settings.values
      end
      
      it 'should neither assign user-name nor password' do
        ActionMailer::Base.should_receive(:smtp_settings=).with(
          :enable_starttls_auto => true,
          :address => 'mail.mydomain.com', 
          :port => 225, 
          :domain => 'mydomain.com',
          :authentication => nil, 
          :user_name => nil, 
          :password => nil)
        Notifications.reload_settings
      end      

    end    
    
    
    describe 'if user name or password are blank' do

      before do 
        @settings[:user_name].stub!(:value).and_return ''
        @settings[:password].stub!(:value).and_return ''
        RetroCM[:email][:smtp].stub!(:settings).and_return @settings.values
      end
      
      it 'should neither assign authentication settings' do
        ActionMailer::Base.should_receive(:smtp_settings=).with(
          :enable_starttls_auto => true,
          :address => 'mail.mydomain.com', 
          :port => 225, 
          :domain => 'mydomain.com',
          :authentication => nil, 
          :user_name => nil, 
          :password => nil)
        Notifications.reload_settings
      end      

    end

  end
  

  describe 'account activation' do
    fixtures :users
    
    def do_deliver(options = {})
      Notifications.deliver_account_activation_note(users(:agent))
      ActionMailer::Base.deliveries
    end

    it 'should send one message to the activated user' do
      do_deliver.should have(1).record
    end

    it 'should use correct headers' do
      mail = do_deliver.first
      mail.from.should == [RetroCM[:email][:general][:from]]
      mail.to.should == [users(:agent).email]
      mail.subject.should == "[#{RetroCM[:general][:basic][:site_name]}] Account activation"
    end

    it 'should send correct body' do
      mail = do_deliver.first
      mail.body.should == fixture(:account_activation_note)
    end
    
  end

  describe 'account validation' do
    fixtures :users
    
    def do_deliver(options = {})
      Notifications.deliver_account_validation(users(:inactive))
      ActionMailer::Base.deliveries
    end

    it 'should send one message to the to be validated user' do
      do_deliver.should have(1).record
    end

    it 'should use correct headers' do
      mail = do_deliver.first
      mail.from.should == [RetroCM[:email][:general][:from]]
      mail.to.should == [users(:inactive).email]
      mail.subject.should == "[#{RetroCM[:general][:basic][:site_name]}] Account validation"
    end

    it 'should send correct body' do
      mail = do_deliver.first
      mail.body.should == fixture(:account_validation)
    end
    
  end


  describe 'ticket creation' do
    fixtures :projects, :tickets, :users, :statuses, :priorities
    
    before do
      Project.stub!(:current).and_return(nil)
      @ticket = tickets(:agents_ticket)
      @ticket.stub!(:created_at).and_return(Time.local(2008, 1, 1))
    end
    
    def do_deliver(options = {})
      Notifications.deliver_ticket_creation_note(@ticket, :recipients => users(:agent).email)
      ActionMailer::Base.deliveries
    end

    it 'should send one message to the author' do
      do_deliver.should have(1).record
    end

    it 'should use correct headers' do
      mail = do_deliver.first
      mail.from.should == [RetroCM[:email][:general][:from]]
      mail.to.should == [users(:agent).email]
      mail.subject.should == "[#{RetroCM[:general][:basic][:site_name]}] Ticket #4 (Open) reported by Agent - Agent's request"
    end

    it 'should send correct body' do
      mail = do_deliver.first
      mail.body.should == fixture(:ticket_creation_note)
    end    
  end

  describe 'ticket update' do
    fixtures :projects, :tickets, :ticket_changes, :users, :statuses, :priorities
    
    before do
      Project.stub!(:current).and_return(nil)
      @change = ticket_changes(:special_update_last)
    end
    
    def do_deliver(options = {})
      Notifications.deliver_ticket_update_note(@change, :recipients => users(:agent).email)
      ActionMailer::Base.deliveries
    end

    it 'should send one message to those watching the ticket' do
      do_deliver.should have(1).record
    end

    it 'should use correct headers' do
      mail = do_deliver.first
      mail.from.should == [RetroCM[:email][:general][:from]]
      mail.to.should == [users(:agent).email]
      mail.subject.should == "[#{RetroCM[:general][:basic][:site_name]}] Ticket #9 (Open) changed by Me - Link with '&'"
    end

    it 'should send correct body' do
      mail = do_deliver.first
      mail.body.should == fixture(:ticket_update_note)
    end
    
  end


  describe 'password recovery instructions' do
    fixtures :users
    
    before do
      @user = users(:agent)
      @user.login_tokens.stub!(:generate).and_return('LT-123-KEY')
    end
    
    def do_deliver(options = {})
      Notifications.deliver_password_reset_instructions(@user)
      ActionMailer::Base.deliveries
    end

    it 'should send one message to the user' do
      do_deliver.should have(1).record
    end

    it 'should use correct headers' do
      mail = do_deliver.first
      mail.from.should == [RetroCM[:email][:general][:from]]
      mail.to.should == [@user.email]
      mail.subject.should == "[#{RetroCM[:general][:basic][:site_name]}] Password reset"
    end

    it 'should send correct body' do
      mail = do_deliver.first
      mail.body.should == fixture(:password_reset_instructions)
    end
    
  end


end
