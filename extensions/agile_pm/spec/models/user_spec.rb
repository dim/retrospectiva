require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  fixtures :milestones, :projects, :users, :goals, :sprints, :stories, :story_events
  
  it 'should have many requested goals' do
    users(:creator).should have(4).requested_goals
  end

  it 'should have many created stories' do
    users(:creator).should have(5).created_stories
  end

  it 'should have many created story events' do
    users(:creator).should have(1).created_story_events
  end
  
  it 'should have many assigned stories' do
    users(:worker).should have(3).assigned_stories
  end
  
  describe 'if user is deleted' do
    
    it 'should assign public to created stories' do
      users(:creator).destroy
      stories(:active).creator.should == users(:Public)
    end
    
    it 'should assign public to created story-events' do
      users(:creator).destroy
      story_events(:comment).creator.should == users(:Public)
    end

    it 'should remove association from requested-goals' do
      users(:creator).destroy
      goals(:must_have).requester.should be_nil
    end

    it 'should remove association from assigned stories' do
      users(:worker).destroy
      stories(:active).assigned.should be_nil
    end
    
  end

end

