require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Priority do

  describe 'class' do
    fixtures :statuses
    
    it "should be a global ticket property" do
      Priority.should be_global
    end
  
    it "should find the default record" do
      Priority.default.should be_kind_of(Priority)
      Priority.default.should be_default_value
    end
    
    it 'should have a label' do
      Priority.label.should == 'Priority'
    end
    
  end  

  describe 'instance' do
    before do
      @priority = Priority.new
    end
    
    it "should have many tickets" do
      @priority.should have_many(:tickets)
      @priority.tickets.should have(0).records
    end
  
    it "should validate presence of name" do
      @priority.should validate_presence_of(:name)
    end

    it "should validate uniqueness of name" do
      @priority.should validate_uniqueness_of(:name)
    end
  end

  describe 'on save' do
    fixtures :priorities
    
    describe 'if default-value was assigned' do
      it 'should automatically unset default-value status of other records' do
        priorities(:normal).should be_default_value
        priorities(:minor).default_value = true
        priorities(:minor).save.should be(true)
        priorities(:normal).reload.should_not be_default_value        
      end
    end
  end

  describe 'on destroy' do
    fixtures :priorities
    
    describe 'of a default record' do
      it 'should refuse to delete it' do
        priorities(:normal).should be_default_value
        priorities(:normal).destroy.should be(false)
      end
    end

    describe 'of a non-default record' do
      it 'should delete it as usual' do
        priorities(:minor).should_not be_default_value
        priorities(:minor).destroy.should_not be(false)
      end
    end
  end
  
  describe 'on update' do
    fixtures :priorities
    
    describe 'when default-status was unset' do
      it 'should refuse to update it' do
        priorities(:normal).should be_default_value
        priorities(:normal).default_value = false
        priorities(:normal).should have(1).error_on(:default_value)
      end
    end
  end
  
end