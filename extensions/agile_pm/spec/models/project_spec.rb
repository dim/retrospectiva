require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do
  fixtures :milestones, :projects

  it 'should have many sprints' do
    projects(:retro).should have_many(:sprints)
  end
  
end

