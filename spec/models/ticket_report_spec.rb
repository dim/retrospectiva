require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TicketReport do
  before(:each) do
    @ticket_report = TicketReport.new
  end

  it "should belong to a project" do
    @ticket_report.should belong_to(:project)
  end
  
  it "should validate presence of name" do
    @ticket_report.should validate_presence_of(:name)
  end

  it "should validate presence of filter options" do
    @ticket_report.should validate_presence_of(:filter_options)
  end

  it "should validate presence of project" do
    @ticket_report.should validate_presence_of(:project_id)
  end

  it "should validate uniqueness of name" do
    @ticket_report.should validate_uniqueness_of(:name)
  end
  
  it "should validate numeric time intervals" do
    @ticket_report.should validate_numericality_of(:time_interval, :min => 1.day, :nil => true)
  end  
  
  describe 'time interval assignement' do
    
    it 'should accept seconds' do
      @ticket_report.time_interval = 3600
      @ticket_report.time_interval.should == 3600
    end

    it 'should not accept interval options with minutes' do
      @ticket_report.time_interval = {:count => '10', :units => 'minutes'}
      @ticket_report.time_interval.should be_nil
    end

    it 'should not accept interval options with hours' do
      @ticket_report.time_interval = {:count => '1', :units => 'hours'}
      @ticket_report.time_interval.should be_nil
    end

    it 'should accept interval options with days' do
      @ticket_report.time_interval = {:count => '10', :units => 'days'}
      @ticket_report.time_interval.should == 10.days
    end

    it 'should accept interval options with weeks' do
      @ticket_report.time_interval = {:count => '2', :units => 'weeks'}
      @ticket_report.time_interval.should == 2.weeks
    end
    
    it 'should accept interval options with months' do
      @ticket_report.time_interval = {:count => '6', :units => 'months'}
      @ticket_report.time_interval.should == 6.months
    end

    it 'should accept invalid interval options' do
      @ticket_report.time_interval = {:units => 'months'}
      @ticket_report.time_interval.should be_nil
      @ticket_report.time_interval = 'ABC'
      @ticket_report.time_interval.should be_nil
    end

  end
  
end

