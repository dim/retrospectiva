require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Sprint do
  fixtures :milestones, :projects, :users, :goals, :sprints, :stories
  
  it 'should belong to milestone' do
    sprints(:current).should belong_to(:milestone)
  end

  it 'should have many goals' do
    sprints(:current).should have_many(:goals)
  end
  
  it 'should have many stories' do
    sprints(:current).should have_many(:stories)
  end

  it 'should have many progress updates' do
    sprints(:current).should have_many(:progress_updates)
  end

  it 'should validate presence of title' do
    sprints(:current).should validate_presence_of(:title)
  end

  it 'should validate presence of starts-on' do
    sprints(:current).should validate_presence_of(:starts_on)
  end

  it 'should validate presence of finishes-on' do
    sprints(:current).should validate_presence_of(:finishes_on)
  end

  it 'should validate uniqueness of title (within a milestone)' do
    sprints(:current).should validate_uniqueness_of(:title)
  end

  it 'should validate presence of milestone' do
    sprints(:current).should validate_association_of(:milestone)
  end

  it 'should validate correctness of start-date and end-date' do
    sprints(:current).finishes_on = sprints(:current).starts_on - 1
    sprints(:current).should have(1).error_on(:finishes_on)
  end

  it 'should iterate through sprint days' do
    result = []
    sprints(:current).each_day do |date|
      result << date
    end
    result.should have(15).items
  end

  it 'should calculate an amount of remaining hours for any given date' do 
    sprints(:current).remaining_hours(2.weeks.ago.to_date).should == 59
    sprints(:current).remaining_hours(4.days.ago.to_date).should == 52
    sprints(:current).remaining_hours(2.days.ago.to_date).should == 40
    sprints(:current).remaining_hours(Time.zone.today).should == 24.4
  end

  it 'should have a time-line' do
    sprints(:current).time_line.keys.should == [nil] + (-7..7).map {|i| Time.zone.today + i }
    sprints(:current).time_line.values.should == [59, 59, 59, 53, 52, 50, 40] + ([24] * 9)
  end

  describe 'the class' do

    it 'should identify currently relevant sprints' do
      Sprint.in_order_of_relevance.should == sprints(:current, :future, :previous)
    end
    
  end
  
end

