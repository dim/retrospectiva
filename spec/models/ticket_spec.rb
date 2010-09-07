require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Ticket do
  fixtures :all

  def build_ticket
    @ticket.project = projects(:retro)
    @ticket.user = users(:agent)
    @ticket.status = statuses(:open)
    @ticket.priority = priorities(:normal)
    @ticket.summary = 'New ticket'
    @ticket.content = 'New content'
    @ticket
  end

  describe 'associations' do

    before(:each) do
      @ticket = Ticket.new
    end

    it "should belong to a project" do
      @ticket.should belong_to(:project)
    end

    it "should belong to a status" do
      @ticket.should belong_to(:status)
    end

    it "should belong to a priority" do
      @ticket.should belong_to(:priority)
    end

    it "can belong to a milestone" do
      @ticket.should belong_to(:milestone)
    end

    it "can be associated with a user (author)" do
      @ticket.should belong_to(:user)
    end

    it "can be assigned to a user (contributer)" do
      @ticket.should belong_to(:assigned_user)
    end

    it "has many changes" do
      @ticket.should have_many(:changes)
    end

    it "has and belongs to many subscribers" do
      @ticket.should have_and_belong_to_many(:subscribers)
    end

    it "has and belongs to many properties" do
      @ticket.should have_and_belong_to_many(:properties)
    end
    
  end
  
  describe 'updating' do

    before(:each) do
      @ticket = tickets(:another_open)
    end

    it 'should be able to update the updated-timestamp only' do
      @ts = 2.years.ago
      @ticket.update_timestamp(@ts)
      @ticket.updated_at.to_formatted_s(:db).should == @ts.to_formatted_s(:db)
    end

  end


  describe 'toggle subscriptions' do
    
    before do
      @user = users(:agent)
      @open = tickets(:open)
      @fixed = tickets(:fixed)
    end
    
    describe 'if user is not subscribed' do

      it 'should remove the subscription' do
        @open.subscribers.should include(@user)
        @open.toggle_subscriber(@user).should be(false)
        @open.subscribers.should_not include(@user)
      end

    end

    describe 'if user is subscribed' do

      it 'should add the user if user is permitted' do
        @fixed.subscribers.should_not include(@user)
        @user.should_receive(:permitted?).with(:tickets, :watch, :project => @fixed.project).and_return(true)
        @fixed.toggle_subscriber(@user).should be(true)
        @fixed.subscribers.should include(@user)
      end
  
      it 'should NOT add the user if user is not permitted' do
        @fixed.subscribers.should_not include(@user)
        @user.should_receive(:permitted?).with(:tickets, :watch, :project => @fixed.project).and_return(false)
        @fixed.toggle_subscriber(@user).should be(false)
        @fixed.subscribers.should_not include(@user)
      end    

    end
  end

  
  describe 'modifiable status' do

    it 'should return false if no user is assigned' do
      tickets(:another_open).send(:modifiable?, users(:agent)).should == false
    end

    describe 'if author-modification is on' do
      it 'should return true if user is the author' do
        RetroCM[:ticketing][:author_modifiable].should_receive(:[]).with(:tickets).and_return(true)
        tickets(:agents_ticket).send(:modifiable?, users(:agent)).should == true
      end

      it 'should return false if user is not the author' do
        RetroCM[:ticketing][:author_modifiable].should_receive(:[]).with(:tickets).and_return(true)
        tickets(:agents_ticket).send(:modifiable?, users(:double_agent)).should == false
      end      
    end

    describe 'if author-modification is off' do
      it 'should return false' do
        RetroCM[:ticketing][:author_modifiable].should_receive(:[]).with(:tickets).and_return(false)
        tickets(:agents_ticket).send(:modifiable?, users(:agent)).should == false
      end
    end
  end
  
  describe 'determination of permitted subscribers' do
    
    before do
      RetroCM[:ticketing][:subscription].stub!(:[]).with(:notify_author).and_return(false)
      @agent = users(:agent)
      @ticket = tickets(:open)
    end
    
    it 'should list all subscribed users' do
      @ticket.permitted_subscribers.should have(1).record
      @ticket.permitted_subscribers.should include(@agent)
    end

    it 'should exclude subscribed users that have no (more) permission to view the ticket' do
      @agent.should_receive(:permitted?).with(:tickets, :view, :project => projects(:retro)).and_return(false)
      @ticket.stub!(:subscribers).and_return([@agent])
      @ticket.permitted_subscribers.should have(:no).records
    end
    
    it 'should exclude subscribed users that have no (more) permission to watch the ticket' do
      @agent.stub!(:permitted?).and_return(true)
      @agent.should_receive(:permitted?).with(:tickets, :watch, :project => projects(:retro)).and_return(false)
      @ticket.stub!(:subscribers).and_return([@agent])
      @ticket.permitted_subscribers.should have(:no).records
    end

    it 'should always exclude the public user' do
      @ticket.stub!(:subscribers).and_return([users(:Public)])
      @ticket.permitted_subscribers.should have(:no).records
    end

    it 'should by default exclude the creator (if passed)' do
      @ticket.permitted_subscribers.should == [@agent]
      @ticket.permitted_subscribers(@agent).should == []
    end

    it 'should include the creator (if configured to do so)' do
      RetroCM[:ticketing][:subscription].should_receive(:[]).with(:notify_author).twice.and_return(true)
      @ticket.permitted_subscribers.should == [@agent]      
      @ticket.permitted_subscribers(@agent).should == [@agent]
    end

  end

  
  describe 'assigning custom properties' do
   
    describe 'a new record' do
      
      before do 
        @ticket = Ticket.new
      end
      
      it 'should store the properties a usual' do
        @ticket.should_receive(:original_property_ids=).with([1, 3]).and_return(true)
        @ticket.property_ids = [1, 3]
      end

      it 'should retrieve the property-ids as usual' do
        @ticket.should_receive(:original_property_ids).and_return([1, 3])
        @ticket.property_ids
      end
      
    end

    describe 'an exisiting record' do
      
      before do 
        @ticket = tickets(:open)
      end
      
      it 'should store the properties in an variable until the ticket is saved' do
        @ticket.should_not_receive(:original_property_ids=)
        @ticket.property_ids = [1, 3]
      end

      it 'should retrieve the property-ids as usual unless they were changed' do
        @ticket.property_ids.should == [1]
        @ticket.property_ids = [1, 3]
        @ticket.property_ids.should == [1, 3]
        @ticket.properties.map(&:id).should == [1]
      end
      
      describe 'on save' do

        it 'should apply the property changes' do
          @ticket.property_ids = [1, 3]
          @ticket.save.should be_true
          @ticket.properties.map(&:id).should == [1, 3]
        end
        
        it 'should drop all non-matching properties' do
          @ticket.property_ids = [3, 5]
          @ticket.save.should be_true
          @ticket.properties.map(&:id).should == [3]
        end

        it 'should store only one property per property-type' do
          @ticket.property_ids = [1, 2, 3, 4]
          @ticket.save.should be_true
          @ticket.properties.should have(2).records
          @ticket.properties.map(&:ticket_property_type_id).sort.should == [1, 2]
        end
        
      end
      
    end
   
  end

  
  describe 'an instance' do
   
    before(:each) do
      @filter = mock(TicketFilter::Collection, :conditions => ['statuses.state_id = 1'], :joins => nil)
      @ticket = tickets(:another_open)
    end

    it "should be able to find the next record" do
      @ticket.next_ticket(@filter).should == tickets(:agents_ticket)
    end

    it "should make the right call when finding the next record" do
      @ticket.stub!(:updated_at).and_return('[TODAY]')
      Ticket.should_receive(:default_includes).and_return(nil)
      Ticket.should_receive(:find).with(:first,
        :conditions=>["( statuses.state_id = 1 ) AND ( tickets.updated_at > ? ) AND ( tickets.project_id = ? )", '[TODAY]', 1],
        :joins=>nil, :order=>"tickets.updated_at ASC", :include=> nil)
      @ticket.next_ticket(@filter)
    end

    it "should be able to find the previous record" do
      @ticket.previous_ticket(@filter).should == tickets(:open)
    end

    it "should make the right call when finding the previous record" do
      @ticket.stub!(:updated_at).and_return('[TODAY]')
      Ticket.should_receive(:default_includes).and_return(nil)
      Ticket.should_receive(:find).with(:first,
        :conditions=>["( statuses.state_id = 1 ) AND ( tickets.updated_at < ? ) AND ( tickets.project_id = ? )", '[TODAY]', 1],
        :joins=>nil, :order=>"tickets.updated_at DESC", :include=> nil)
      @ticket.previous_ticket(@filter)
    end
    
    it 'should allow to update attributes without changing the timestamps' do
      original = @ticket.updated_at
      @ticket.update_attribute_without_timestamps :status_id, 2
      @ticket.updated_at.should == original
    end
    
    it 'should allow to assign protected attributes' do
      @ticket.protected_attributes = { :author => 'Me', :email => 'me@home', :content => 'New content', :summary => 'New summary'  }
      @ticket.author.should == 'Me'
      @ticket.email.should == 'me@home'
      @ticket.content.should == 'New content'
      @ticket.summary.should == 'New summary'
    end
    
    it 'should be able to determine if the ticket was updated' do
      tickets(:open).should_not be_updated
      tickets(:agents_ticket).should be_updated
      Ticket.new.should_not be_updated
    end

    it 'should be able to determine if the ticket has a readable attachment' do
      tickets(:open).attachment?.should be(false)
    end

  end

      

  describe 'on create' do

    before do
      @ticket = Ticket.new
      Notifications.stub!(:queue_ticket_creation_note)
    end
    
    def build_attachment(content, name = 'file.rb', type = 'text/plain')    
      ActionController::UploadedStringIO.new(content).tap do |stream|
        stream.original_path = name
        stream.content_type = type
      end
    end
    
    it 'should forward all attachment errors to the ticket (if any)' do
      Attachment.stub!(:max_size).and_return(4)
      @ticket.attachment = build_attachment('ABCDE')
      @ticket.should have(2).errors_on(:attachment)
      @ticket.errors.on(:attachment).sort.should == ["File size exceeds the maximum limit", "Upload is not permitted"]
    end
    
    it 'should automatically assign the logged-in user (unless Public)' do
      User.stub!(:current).and_return(users(:Public))
      @ticket.valid?
      @ticket.user.should be_nil

      User.stub!(:current).and_return(users(:agent))
      @ticket.valid?
      @ticket.user.should == users(:agent)
    end

    it 'should overwrite the author field with user values if user is not Public' do
      @ticket.user = users(:agent)
      @ticket.author = 'Me'
      @ticket.valid?
      @ticket.author.should == users(:agent).name
    end

    it 'should overwrite the email field with user values if user is not Public' do
      @ticket.user = users(:agent)
      @ticket.email = 'me@home.net'
      @ticket.valid?
      @ticket.email.should == users(:agent).email
    end   

    it 'should update the existing-tickets cache in parent project' do
      @ticket = build_ticket
      @ticket.save.should be(true)            
      projects(:retro).existing_tickets[@ticket.id][:summary].should == 'New ticket'
    end

    it 'should send a notification to the subscribed users' do
      @ticket = build_ticket
      @ticket.subscribers << users(:admin)
      Notifications.should_receive(:queue_ticket_creation_note).with(@ticket, :recipients => 'admin@administration.com')
      @ticket.save.should be(true)
    end
    
    describe 'if subscription on assignment is enabled' do
      before do
        RetroCM[:ticketing][:subscription].stub!(:[]).with(:notify_author).and_return(false)
        RetroCM[:ticketing][:subscription].stub!(:[]).with(:subscribe_on_assignment).and_return(true)
      end
      
      it 'should first subscribe the user and then send the notification' do
        @ticket = build_ticket
        @ticket.assigned_user = users(:admin)
        Notifications.should_receive(:queue_ticket_creation_note).with(@ticket, :recipients => 'admin@administration.com')
        @ticket.save.should be(true)
      end
      
    end

  end
  
  
  describe 'on save' do
    
    before do
      @ticket = Ticket.new
    end

    it 'should drop the assigned user unless the user is permitted to update the ticket' do
      users(:inactive).should_receive(:permitted?).with(:tickets, :update, :project => projects(:retro)).and_return(false)
      tickets(:agents_ticket).assigned_user = users(:inactive)
      tickets(:agents_ticket).valid?
      tickets(:agents_ticket).assigned_user.should be_nil
    end

    it 'should drop the assigned user if the assigned user is Public' do
      tickets(:agents_ticket).assigned_user = users(:Public)
      tickets(:agents_ticket).valid?
      tickets(:agents_ticket).assigned_user.should be_nil
    end

    it 'should validate that an assigned milestone belongs to the same project as th ticket' do
      tickets(:open).milestone = milestones(:sub_ongoing)
      tickets(:open).should have(1).error_on(:milestone_id)
    end

    it 'should validate that an assigned milestone was active by the time the ticket was created' do
      tickets(:open).milestone = milestones(:retro_completed)
      tickets(:open).should have(1).error_on(:milestone_id)
    end

    it 'should validate presence of name' do
      @ticket.should validate_presence_of(:author)
    end

    it 'should validate presence of summary' do
      @ticket.should validate_presence_of(:summary)
    end

    it 'should validate presence of content' do
      @ticket.should validate_presence_of(:content)
    end

    it 'should validate association of status' do
      @ticket.should validate_association_of(:status)
    end

    it 'should validate association of priority' do
      @ticket.should validate_association_of(:priority)
    end

    it 'should validate association of project' do
      @ticket.should validate_association_of(:project)
    end

    it 'should nullify the email if blank' do
      @ticket.email = ' '
      @ticket.valid?
      @ticket.email.should be_nil
    end

    it 'should update the existing-tickets cache in parent project' do
      projects(:retro).existing_tickets[tickets(:another_open).id][:summary].should == 'Another open'
      projects(:retro).existing_tickets[tickets(:another_open).id][:state].should == 1
      
      tickets(:another_open).summary = 'Now closed'
      tickets(:another_open).save.should be_true
      projects(:retro).reload.existing_tickets[tickets(:another_open).id][:summary].should == 'Now closed' 
      projects(:retro).reload.existing_tickets[tickets(:another_open).id][:state].should == 1 

      tickets(:another_open).status = statuses(:fixed)
      tickets(:another_open).save.should be_true
      projects(:retro).reload.existing_tickets[tickets(:another_open).id][:summary].should == 'Now closed' 
      projects(:retro).reload.existing_tickets[tickets(:another_open).id][:state].should == 3      
    end

    describe 'if a user was assigned' do

      before do
        RetroCM[:ticketing][:subscription].stub!(:[]).with(:notify_author).and_return(false)
        RetroCM[:ticketing][:subscription].stub!(:[]).with(:subscribe_on_assignment).and_return(true)
        @ticket = build_ticket
        @ticket.assigned_user = users(:agent)
      end

      it 'should check for subscription-on-assignment setting' do
        RetroCM[:ticketing][:subscription].should_receive(:[]).with(:subscribe_on_assignment).and_return(false)          
        @ticket.save.should be(true)            
      end

      describe 'if subscription-on-assignment is inactive' do
                
        it 'should not subscribe the user' do
          RetroCM[:ticketing][:subscription].should_receive(:[]).with(:subscribe_on_assignment).and_return(false)          
          @ticket.save.should be(true)            
          @ticket.subscribers(true).should be_empty
        end

      end
      
      describe 'if subscription-on-assignment is active' do
        
        it 'should not subscribe the user if user is not permitted to watch the ticket' do
          @ticket.assigned_user = users(:inactive)
          @ticket.save.should be(true)
          @ticket.subscribers(true).should == []
        end

        it 'should subscribe the user if user is permitted to watch the ticket' do
          @ticket.save.should be(true)
          @ticket.subscribers(true).should == [users(:agent)]
        end
        
      end
      
    end

  end


  describe 'on delete' do

    it 'should remove the ticket reference from the existing-tickets cache in parent project' do
      projects(:retro).existing_tickets[tickets(:another_open).id].should_not be_blank      
      tickets(:another_open).destroy
      projects(:retro).reload.existing_tickets[tickets(:another_open).id].should be_blank      
    end
        
  end


  describe 'previewable' do  
    
    describe 'channel' do
      before do
        @channel = Ticket.previewable.channel(:project => projects(:retro))
      end
      
      it 'should have a valid name' do
        @channel.name.should == 'tickets'
      end
      
      it 'should have a valid title' do
        @channel.title.should == 'Tickets'
      end
      
      it 'should have a valid description' do
        @channel.description.should == 'Tickets for Retrospectiva'
      end
      
      it 'should have a valid link' do
        @channel.link.should == 'http://test.host/projects/retrospectiva/tickets'
      end      

    end

    describe 'items' do
      before do
        @ticket = tickets(:open)
        @item = @ticket.previewable
      end
      
      it 'should have a valid title' do
        @item.title.should == "Ticket ##{@ticket.id} (Open) reported by John Doe - An open ticket"
      end
      
      it 'should have a valid description' do
        @item.description.should == @ticket.content
      end
      
      it 'should have a valid link' do
        @item.link.should == "http://test.host/projects/retrospectiva/tickets/#{@ticket.id}"
      end
      
      it 'should have a date' do
        @item.date.should == @ticket.created_at
      end      
      
    end
    
  end

  describe 'generating RSS' do

    before do
      Project.stub!(:current).and_return(projects(:retro))
    end
   
    it 'should flatten the records' do
      Ticket.should_receive(:flatten_and_sort).with([]).and_return([])
      Ticket.to_rss([])      
    end

   
    it 'should work correctly' do
      rss = Ticket.to_rss([tickets(:open)]).to_s
      rss.should match(/<description>Tickets for Retrospectiva<\/description>/)
      rss.should match(/Ticket #1 \(Open\) reported by John Doe/)
    end
  end

  describe '\'flattening\' records' do

    before do
      Project.stub!(:current).and_return(projects(:retro))
      @records = Ticket.send(:flatten_and_sort, tickets(:agents_ticket, :another_open))
    end
    
    it 'should mix tickets with ticket-changes' do
      @records.should have(4).records
      @records.map {|i| i.class.name }.should == ['Ticket', 'TicketChange', 'Ticket', 'TicketChange']      
      @records.map(&:id).should == [3, 2, 4, 1]
    end
   
  end

end
