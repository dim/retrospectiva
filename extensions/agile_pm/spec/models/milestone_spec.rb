require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Milestone do
  fixtures :milestones, :projects

  it 'should sort by relevance' do
    Milestone.in_order_of_relevance.find(:all).map(&:id).should == milestones(:upcoming, :completed, :unscheduled).map(&:id)
  end  
  
  it 'should have many sprints' do
    milestones(:upcoming).should have_many(:sprints)
  end

  it 'should have many goals' do
    milestones(:upcoming).should have_many(:goals)
  end
  
end

