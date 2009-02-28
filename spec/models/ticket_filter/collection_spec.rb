require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe TicketFilter::Collection do

  before do
    @project = mock_model(Project)
    
    @state = mock_model(Status::State, :name => 'Open')
    @statuses = [mock_model(Status, :name => 'St1', :state => @state), mock_model(Status, :name => 'St2', :state => @state)]
    Status.stub!(:find).and_return(@statuses)

    @priorities = [mock_model(Priority, :name => 'Pr1')]
    Priority.stub!(:find).and_return(@priorities)
    
    @milestones = [mock_model(Milestone, :name => 'Mi1')]
    @project.stub!(:milestones).and_return(@milestones)
    @milestones.stub!(:find).and_return(@milestones)      
    
    @ticket_properties = [mock_model(TicketProperty, :name => '1.0.0')]
    @ticket_property_types = [mock_model(TicketPropertyType, :name => 'Tpt1', :class_name => 'Release', :ticket_properties => @ticket_properties)]
    @project.stub!(:ticket_property_types).and_return(@ticket_property_types)
    @ticket_property_types.stub!(:find).and_return(@ticket_property_types)      
  end

  def do_create(params = {})
    TicketFilter::Collection.new(params, @project)
  end

  describe 'creating a new collection' do
    
    it 'should find and assign the status records' do
      Status.should_receive(:find).with(:all, :order => 'rank').and_return(@statuses)
      do_create.send(:statuses).should == @statuses
    end

    it 'should find and assign the priority records' do
      Priority.should_receive(:find).with(:all, :order => 'rank').and_return(@priorities)
      do_create.send(:priorities).should == @priorities
    end
    
    it 'should find and assign the milestone records' do
      @milestones.should_receive(:find).with(:all, :order => 'rank').and_return(@milestones)      
      do_create.send(:milestones).should == @milestones
    end

    it 'should find and assign the ticket property records' do
      @ticket_property_types.should_receive(:find).
        with(:all, :include => :ticket_properties).
        and_return(@ticket_property_types)      
      do_create.send(:ticket_properties).should == @ticket_property_types
    end

    it 'should find and assign the states' do
      @statuses.first.should_receive(:state).and_return(@state)
      do_create.send(:states).should == [@state]
    end

  end


  describe 'using the collection for params generation' do
    
    before do
      @status = @statuses.first
      @ticket_property = @ticket_properties.first
      User.stub!(:current).and_return(mock_model(User, :public? => false))
    end
           
    it 'should return no params if nothing is selected' do
      do_create().to_params.should == {}
    end

    it 'should return only the selected params' do
      do_create(:status => @status.id).to_params.should == {'status' => [@status.id]}
    end

    it 'should accept arrays if IDs as well' do
      do_create(:status => [@status.id]).to_params.should == {'status' => [@status.id]}
    end

    it 'should ignore invalid fields' do
      do_create(:something => [@status.id], :status => [@status.id], :release => [@ticket_property.id]).to_params.keys.sort.should == ['release', 'status']
    end

    it 'should ignore invalid ID values' do
      do_create(:status => [-1, -2]).to_params.should == {}
      do_create(:status => [-1, -2, @status.id]).to_params.should == {'status' => [@status.id]}
    end

  end


  describe 'custom params generation' do
    
    before do
      @s1, @s2 = @statuses
      @p1 = @priorities.first
      User.stub!(:current).and_return(mock_model(User, :public? => false))
    end

    it 'should allow to include an additional element to an existing filter' do
      do_create(:status => @s1.id).to_params.should == { 'status' => [@s1.id] }
      do_create(:status => @s1.id).including(:status, @s2.id).should == { 'status' => [@s1.id, @s2.id] }
    end

    it 'should allow to exclude an additional element to an existing filter' do
      do_create(:status => @statuses.map(&:id)).to_params.should == { 'status' => [@s1.id, @s2.id] }
      do_create(:status => @statuses.map(&:id)).excluding(:status, @s1.id).should == { 'status' => [@s2.id] }
    end

    it 'should allow to include new filter' do
      do_create(:priority => @p1.id).including(:status, @s1.id).should == { 'priority' => [@p1.id], 'status' => [@s1.id] }
    end

    it 'should allow to remove a filter' do
      do_create(:priority => @p1.id, :status => @s1.id).excluding(:status, @s1.id).should == { 'priority' => [@p1.id] }
    end

  end


  describe 'using the collection for conditions generation' do
    
    before do
      @status = @statuses.first
      @priority = @priorities.first
      @user = mock_model(User, :public? => false)
      User.stub!(:current).and_return(@user)
    end
           
    it 'should generate simple clauses' do
      do_create(:status => @status.id).conditions.should == ['( statuses.id IN (?) )', [@status.id]]
    end

    it 'should generate complex clauses' do
      do_create(:status => @status.id, :priority => @priority.id).conditions.should == ['( statuses.id IN (?) ) AND ( priorities.id IN (?) )', [@status.id], [@priority.id]]
    end

    it 'should generate custom clauses' do
      do_create(:my_tickets => 1).conditions.should == ["( ( tickets.assigned_user_id = ? ) )", @user.id]
    end

  end

  describe 'using the collection for joins generation' do
    
    before do
      @ticket_property = @ticket_properties.first
      User.stub!(:current).and_return(mock_model(User, :public? => false))
    end
           
    it 'should generate clauses' do
      do_create(:release => @ticket_property.id).joins.should == "INNER JOIN ticket_properties_tickets AS ticket_property_release ON ticket_property_release.ticket_property_id IN (#{@ticket_property.id}) AND ticket_property_release.ticket_id = tickets.id"
    end

  end


  describe 'user filters' do
    
    it 'should be available if user is not public' do
      User.stub!(:current).and_return(mock_model(User, :public? => false))
      do_create.map(&:name).should include('my_tickets')
    end

    it 'should be NOT available if user is public' do
      User.stub!(:current).and_return(mock_model(User, :public? => true))
      do_create.map(&:name).should_not include('my_tickets')
    end

  end

end
