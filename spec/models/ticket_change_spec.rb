require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TicketChange do
  fixtures :all

  describe 'an instance' do
    
    before(:each) do
      @ticket_change = TicketChange.new
    end

    it 'should provide transparent accessors changeable ticket attributes' do
      Ticket.attr_accessible.each do |name|
        @ticket_change.should respond_to(name)
        @ticket_change.should respond_to("#{name}=")        
      end
    end
    
    it 'should not allow to directly assign an attachment' do
      @ticket_change.attributes = { :attachment => StringIO.new('TEST') }
      @ticket_change.attachment.should be_nil
    end

    it 'should not allow to directly assign update details' do
      @ticket_change.attributes = { :updates => {'key' => 'value'} }
      @ticket_change.updates.should == {}
    end

    it 'should return the correct value for attachment? depending if attachment is present and readble' do
      @ticket_change.attachment?.should be_false
      
      attachment = mock_model(Attachment, :readable? => false)
      @ticket_change.stub!(:attachment).and_return(attachment)
      @ticket_change.attachment?.should be_false
      
      attachment.stub!(:readable?).and_return(true)
      @ticket_change.attachment?.should be_true
    end

    describe 'evaluation of updates?' do
      
      it 'should return true if attachment is present' do
        @ticket_change.should_receive(:attachment?).and_return(true)
        @ticket_change.updates?.should be_true
      end
      
      it 'should return true if updates were made' do
        @ticket_change.should_receive(:attachment?).and_return(false)
        @ticket_change.should_receive(:updates).and_return({:k => :v})
        @ticket_change.updates?.should be_true
      end
      
      it 'should return false if attachment is not present and no updates were made' do
        @ticket_change.should_receive(:attachment?).and_return(false)
        @ticket_change.should_receive(:updates).and_return({})
        @ticket_change.updates?.should be_false
      end
    
    end    
  end

  describe 'on save' do
    
    before(:each) do
      @ticket_change = TicketChange.new
    end

    it 'should validate presence of author' do
      @ticket_change.should validate_presence_of(:author)
    end
    
    it 'should validate correct association with a ticket' do
      @ticket_change.should validate_association_of(:ticket)
    end

    it 'should nullify the email if blank' do
      @ticket_change.email = ' '
      @ticket_change.valid?
      @ticket_change.email.should be_nil
    end
        
  end


  describe 'on create' do
    
    before(:each) do
      @ticket = tickets(:open)
      @ticket_change = @ticket.changes.new
      Notifications.stub!(:queue_ticket_update_note)
    end

    def build_attachment(content, name = 'file.rb', type = 'text/plain')    
      ActionController::UploadedStringIO.new(content).tap do |stream|
        stream.original_path = name
        stream.content_type = type
      end
    end
    
    it 'should forward all attachment errors to the ticket-change (if any)' do
      Attachment.stub!(:max_size).and_return(4)
      @ticket_change.attachment = build_attachment('ABCDE')
      @ticket_change.should have(2).errors_on(:attachment)
      @ticket_change.errors.on(:attachment).sort.should == ["File size exceeds the maximum limit", "Upload is not permitted"]
    end

    it 'should forward all ticket errors to the ticket-change (if any)' do
      @ticket_change.ticket.status_id = 999
      @ticket_change.ticket.milestone_id = 999
      @ticket_change.should have(1).error_on(:status_id)
      @ticket_change.should have(1).error_on(:milestone_id)
    end
        
    it 'should validate presence of content if an attachment is present' do
      @ticket_change.stub!(:attachment?).and_return(true)
      @ticket_change.should have(1).error_on(:content)
    end

    it 'should validate that either content or updates are present' do
      @ticket_change.should have(1).error_on(:base)
    end

    it 'should automatically assign the logged-in user (unless Public)' do
      User.stub!(:current).and_return(users(:Public))
      @ticket_change.valid?
      @ticket_change.user.should be_nil

      User.stub!(:current).and_return(users(:agent))
      @ticket_change.valid?
      @ticket_change.user.should == users(:agent)
    end

    it 'should overwrite the author field with user values if user is not Public' do
      @ticket_change.user = users(:agent)
      @ticket_change.author = 'Me'
      @ticket_change.valid?
      @ticket_change.author.should == users(:agent).name
    end

    it 'should overwrite the email field with user values if user is not Public' do
      @ticket_change.user = users(:agent)
      @ticket_change.email = 'me@home.net'
      @ticket_change.valid?
      @ticket_change.email.should == users(:agent).email
    end

    it 'should store updates made to the ticket' do
      updates = {'Status' => { :old => 'Open', :new => 'Closed'}}
      @ticket_change.stub!(:updates_index).and_return(updates)
      @ticket_change.valid?
      @ticket_change.updates.should == updates
    end

    it 'should save the ticket and update the timestamp' do
      (@ticket.reload.updated_at > 5.seconds.ago).should be(false)
      @ticket_change.user = users(:agent)
      @ticket_change.content = 'An important update'
      @ticket_change.save.should be(true)
      (@ticket.reload.updated_at > 5.seconds.ago).should be(true)
    end

    it 'should send a notification to the subscribed users' do
      Notifications.should_receive(:queue_ticket_update_note).
        with(@ticket_change, :recipients => 'agent@somedomain.com')
      @ticket_change.ticket = tickets(:open)
      @ticket_change.attributes = { :content => 'ABC', :author => 'Me' }
      @ticket_change.save.should be(true)
    end

  end

  describe 'associations' do

    before(:each) do
      @ticket_change = TicketChange.new
    end

    it "should belong to a ticket" do
      @ticket_change.should belong_to(:ticket)
    end

    it "can be associated with a user (author)" do
      @ticket_change.should belong_to(:user)
    end

    it "can have an attachment" do
      @ticket_change.should have_one(:attachment)
    end
    
  end

  describe 'attachment status' do    
    
    before do 
      @ticket_change = ticket_changes(:agents_ticket_update)
      @attachment = mock_model(Attachment, :readable? => true)
      @ticket_change.stub!(:attachment).and_return(@attachment)      
    end
    
    it 'should return true if attachment is present and readable' do
      @attachment.should_receive(:readable?).and_return(true)
      @ticket_change.attachment?.should == true
    end

    it 'should return false if attachment is not present' do
      @ticket_change.should_receive(:attachment).and_return(nil)
      @ticket_change.attachment?.should == false
    end

    it 'should return false if attachment is not readable' do
      @ticket_change.should_receive(:attachment).and_return(nil)
      @ticket_change.attachment?.should == false
    end
  end
  

  describe 'modifiable status' do
        
    it 'should return false if no user is assigned' do
      ticket_changes(:another_open_update).send(:modifiable?, users(:agent)).should == false
    end

    describe 'if author-modification is on' do
      it 'should return true if user is the author' do
        RetroCM[:ticketing][:author_modifiable].should_receive(:[]).with(:ticket_changes).and_return(true)
        ticket_changes(:agents_ticket_update).send(:modifiable?, users(:agent)).should == true
      end

      it 'should return false if user is not the author' do
        RetroCM[:ticketing][:author_modifiable].should_receive(:[]).with(:ticket_changes).and_return(true)
        ticket_changes(:agents_ticket_update).send(:modifiable?, users(:double_agent)).should == false
      end      
    end

    describe 'if author-modification is off' do
      it 'should return false' do
        RetroCM[:ticketing][:author_modifiable].should_receive(:[]).with(:ticket_changes).and_return(false)
        ticket_changes(:agents_ticket_update).send(:modifiable?, users(:agent)).should == false
      end      
    end    
  end

  
  describe 'monitoring ticket changes' do

    before do
      @ticket = tickets(:open)
      @ticket_change = @ticket.changes.new
    end
    
    it 'should track assigned user changes' do
      @ticket_change.attributes = { :assigned_user_id => users(:agent).id }
      @ticket_change.updates_index.should == { 'Assigned user' => { :old => nil, :new => 'Agent' }} 
    end

    it 'should track status changes' do
      @ticket_change.attributes = { :status_id => statuses(:assigned).id }
      @ticket_change.updates_index.should == { 'Status' => { :old => 'Open', :new => 'Assigned' }} 
    end

    it 'should track priority changes' do
      @ticket_change.attributes = { :priority_id => priorities(:major).id }
      @ticket_change.updates_index.should == { 'Priority' => { :old => 'Normal', :new => 'Major' }} 
    end
    
    it 'should track milestone changes' do
      @ticket_change.attributes = { :milestone_id => nil }
      @ticket_change.updates_index.should == { 'Milestone' => { :old => 'Next release', :new => nil }} 
    end

    it 'should track custom property changes' do
      @ticket_change.attributes = { :property_ids => [2, 3] }
      @ticket_change.updates_index.should == { 
        'Component' => { :old => nil, :new => 'Component A' },  
        'Release' => { :old => 'Release A', :new => 'Release B' }  
      } 
    end

    it 'should track multiple changes' do
      @ticket_change.attributes = { :assigned_user_id => users(:agent).id, :status_id => statuses(:assigned).id, :property_ids => [2] }
      @ticket_change.updates_index.should == { 
        'Assigned user' => { :old => nil, :new => 'Agent' },
        'Status' => { :old => 'Open', :new => 'Assigned' },      
        'Release' => { :old => 'Release A', :new => 'Release B' }  
      } 
    end

  end
  
  describe 'previewable' do  
      
    describe 'channel' do
      
      it 'should have no channel' do
        TicketChange.previewable.channel?.should be(false)
      end

    end

    describe 'items' do
      before do
        @ticket_change = ticket_changes(:agents_ticket_update)
        @item = @ticket_change.previewable(:project => projects(:retro))
      end
      
      it 'should have a valid title' do
        @item.title.should == "Ticket ##{@ticket_change.ticket_id} (Open) changed by Agent - Agent's request"
      end
      
      it 'should have a valid description' do
        @item.description.should == 'Agent\'s update'
      end

      it 'should have a valid description with updates (if any)' do
        @ticket_change = ticket_changes(:special_update_02_properties_and_content)
        @ticket_change.previewable(:project => projects(:retro)).description.
          should == '<ul><li><strong>Status:</strong> Open &rarr; WontFix</li><li><strong>Priority:</strong> Normal &rarr; Minor</li></ul> ' + @ticket_change.content
      end
      
      it 'should have a valid link' do
        @item.link.should == "http://test.host/projects/retrospectiva/tickets/#{@ticket_change.ticket_id}#ch#{@ticket_change.id}"
      end
      
      it 'should have a date' do
        @item.date.should == @ticket_change.created_at
      end      
      
    end
    
  end
  
end
