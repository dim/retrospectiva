require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Goal do
  fixtures :milestones, :projects, :users, :goals, :sprints, :stories
  
  it 'should belong to milestone' do
    goals(:must_have).should belong_to(:milestone)
  end

  it 'should belong to sprint' do
    goals(:must_have).should belong_to(:sprint)
  end

  it 'should belong to requester' do
    goals(:must_have).should belong_to(:requester)
  end

  it 'should validate presence of title' do
    goals(:must_have).should validate_presence_of(:title)
  end

  it 'should validate presence of milestone' do
    goals(:must_have).should validate_association_of(:milestone)
  end

  it 'should validate presence of priority' do
    goals(:must_have).priority_id = 50
    goals(:must_have).should have(1).error_on(:priority_id)
  end

  it 'should ensure that sprint and milestone are matching' do
    goals(:must_have).milestone = milestones(:completed)
    goals(:must_have).should have(1).error_on(:sprint_id)
  end

  describe 'if sprint association is updated' do
    before do
      goals(:current).sprint.should == sprints(:current)
      goals(:current).should have(4).stories
      goals(:current).sprint = sprints(:future)
      goals(:current).save.should be(true)
    end

    it "should 'detach' all started/assigned stories (keeping them assigned to their sprint)" do
      stories(:active, :almost_complete, :complete).each do |story|
        story.goal.should be_nil
        story.sprint.should == sprints(:current)
      end
    end

    it 'should take all pending stories along' do
      goals(:current).stories(true).should == [stories(:pending)]
      stories(:pending).sprint.should == sprints(:future)
    end

  end

  describe 'on create' do
    
    before do
      User.stub!(:current).and_return(users(:worker))
    end
    
    def new_goal(options = {})
      @goal ||= Goal.new(options)
    end
    
    it 'should assign the currently logged-in user as requester' do
      new_goal.valid?
      new_goal.requester.should == users(:worker)
    end

    it 'should allow to have explicit requesters' do
      new_goal( :requester_id => users(:creator).id )
      new_goal.valid?
      new_goal.requester.should == users(:creator)
    end
    
  end

end

