require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Status do
  
  describe 'class' do
    fixtures :statuses
    
    it "should be a global ticket property" do
      Status.should be_global
    end
  
    it "should define possible states" do
      Status.states.should have(3).records
    end
  
    it "should have a label" do
      Status.label.should == 'Status'
    end
  
    it "should find states" do
      Status.state(2).should be_kind_of(Status::State)
      Status.state(6).should be_nil
    end
    
    it "should define possible statements" do
      Status.statements.should have(3).records
    end
  
    it "should find statements" do
      Status.statement(2).should be_kind_of(Status::Statement)
      Status.statement(6).should be_nil
    end

    it "should find the default record" do
      Status.default.should be_kind_of(Status)
      Status.default.should be_default_value
    end
  end  
  
  describe 'instance' do
    fixtures :statuses

    before do
      @status = Status.new
    end
    
    it "should have many tickets" do
      @status.should have_many(:tickets)
      @status.tickets.should have(0).records
    end
  
    it "should validate presence of name" do
      @status.should validate_presence_of(:name)
    end

    it "should validate uniqueness of name" do
      @status.should validate_uniqueness_of(:name)
    end

    it "should validate presence of state" do
      @status.should validate_presence_of(:state_id)
    end
  
    it "should validate presence of statement" do
      @status.should validate_presence_of(:statement_id)
    end

    it "should have a state" do
      statuses(:open).state.should be_kind_of(Status::State)
    end

    it "should have a statement" do
      statuses(:open).statement.should be_kind_of(Status::Statement)
    end
  
  end

  describe 'on save' do
    fixtures :statuses
    
    describe 'if default-value was assigned' do
      it 'should automatically unset default-value status of other records' do
        statuses(:open).should be_default_value
        statuses(:assigned).default_value = true
        statuses(:assigned).save.should be(true)
        statuses(:open).reload.should_not be_default_value        
      end
    end
  end

  describe 'on destroy' do
    fixtures :statuses
    
    describe 'of a default record' do
      it 'should refuse to delete it' do
        statuses(:open).should be_default_value
        statuses(:open).destroy.should be(false)
      end
    end

    describe 'of a non-default record' do
      it 'should delete it as usual' do
        statuses(:assigned).should_not be_default_value
        statuses(:assigned).destroy.should_not be(false)
      end
    end
  end
  
  describe 'on update' do
    fixtures :statuses
    
    describe 'when default-status was unset' do
      it 'should refuse to update it' do
        statuses(:open).should be_default_value
        statuses(:open).default_value = false
        statuses(:open).should have(1).error_on(:default_value)
      end
    end
  end

end
