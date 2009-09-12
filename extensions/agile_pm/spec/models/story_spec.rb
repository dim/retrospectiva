require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Story do
  fixtures :milestones, :projects, :users, :goals, :sprints, :stories, :story_events, :story_progress_updates
  
  it 'must belong to sprint' do
    stories(:active).should belong_to(:sprint)
    stories(:active).should validate_association_of(:sprint)
  end

  it 'can belong to goal' do
    stories(:active).should belong_to(:goal)
  end

  it 'must belong to a "creator"' do
    stories(:active).should belong_to(:creator)
    stories(:active).should validate_association_of(:creator)
  end

  it 'can be assigned to a user' do
    stories(:active).should belong_to(:assigned)
  end

  it 'can have many progress-updates' do
    stories(:active).should have_many(:progress_updates)
    stories(:active).should have(1).progress_updates
  end

  it 'can have many events' do
    stories(:active).should have_many(:events)
  end

  it 'can have many status updates' do
    stories(:active).should have_many(:status_updates)
  end

  it 'can have many comments' do
    stories(:active).should have_many(:comments)
  end
  
  it 'can have many revisions' do
    stories(:active).should have_many(:revisions)
  end

  it 'should validate presence of title' do
    stories(:active).should validate_presence_of(:title)
  end
  
  it 'should validate correctness of estimated hours' do
    stories(:active).should validate_presence_of(:estimated_hours)
    stories(:active).estimated_hours = -10
    stories(:active).should have(1).error_on(:estimated_hours)
  end

  it 'should have a progress index' do
    stories(:almost_complete).progress_index.keys.should == [3.days.ago, 2.days.ago, 1.days.ago].map(&:to_date)
    stories(:almost_complete).progress_index.values.should == [10, 50, 90]
  end

  it 'should calculate the remaining hours for a given date' do
    stories(:almost_complete).remaining_hours(3.weeks.ago.to_date).should == 24
    stories(:almost_complete).remaining_hours(3.days.ago.to_date).should == 21.6
    stories(:almost_complete).remaining_hours(2.days.ago.to_date).should == 12
    stories(:almost_complete).remaining_hours(1.day.ago.to_date).should == 2.4
    stories(:complete).remaining_hours(Time.zone.today).should == 0
    stories(:complete).remaining_hours(2.weeks.from_now.to_date).should == 0
  end


    


  describe 'statuses' do
    
    it 'should have a percent completed status' do
      stories(:pending).percent_completed.should == 0
      stories(:active).percent_completed.should == 50
      stories(:complete).percent_completed.should == 100
    end

    it 'should have a started? status' do
      stories(:pending).should_not be_started
      stories(:active).should be_started
      stories(:complete).should be_started
    end

    it 'should have a completed? status' do
      stories(:pending).should_not be_completed
      stories(:active).should_not be_completed
      stories(:complete).should be_completed
    end

    it 'should have an active? status' do
      stories(:pending).should_not be_active
      stories(:active).should be_active
      stories(:complete).should_not be_active
    end

    it 'should have an assigned? status' do
      stories(:pending).should_not be_assigned
      stories(:active).should be_assigned
      stories(:complete).should be_assigned
    end

    it 'should have an orphanned? status' do
      stories(:pending).should_not be_orphanned
      stories(:active).should_not be_orphanned
      stories(:complete).should_not be_orphanned
      stories(:orphanned).should be_orphanned
    end

    it 'should have an assigned_to? status' do
      stories(:active).assigned_to?(users(:worker)).should be(true)
      stories(:active).assigned_to?(users(:creator)).should be(false)
    end

    it 'should detect the status for a given date' do
      stories(:complete).status_on(2.weeks.ago).should == :pending      
      stories(:complete).status_on(5.days.ago).should == :active      
      stories(:complete).status_on(1.minute.ago).should == :completed
    end
    
  end

  describe 'actions' do
    
    it 'should perform correct steps when story is accepted' do
      stories(:pending).accept!(users(:worker))
      stories(:pending).started_at.should be_present
      stories(:pending).assigned.should == users(:worker)      
    end    

    it 'should perform correct steps when story is completed' do
      stories(:active).complete!(users(:creator))
      stories(:active).completed_at.should be_present
      stories(:active).assigned.should == users(:creator)      
    end    

    it 'should perform correct steps when story is re-opened' do
      stories(:complete).reopen!(users(:creator))
      stories(:complete).completed_at.should be_nil
      stories(:complete).assigned.should == users(:creator)      
    end    
    
  end

  describe 'the update' do
    before do
      User.stub!(:current).and_return users(:worker)
    end
  
    it 'should automatically correct revised hours' do
      stories(:active).revised_hours = -10
      stories(:active).valid?
      stories(:active).revised_hours.should == 0
    end

    it 'should create a progress update (100) if a story was completed' do
      stories(:active).completed_at = Time.zone.now
      stories(:active).save.should be(true)
      stories(:active).progress_updates.sort_by(&:created_on).last.percent_completed.should == 100 
    end

    it 'should create a track event if a story was assigned' do
      stories(:active).assigned_to = users(:creator).id
      stories(:active).save.should be(true)
      ev = stories(:active).status_updates.last
      ev.content.should == 'accepted' 
      ev.creator.should == users(:creator)
    end

    it 'should create a track revision when hours were updated' do
      stories(:active).revised_hours = 22
      stories(:active).save.should be(true)
      ev = stories(:active).revisions.last
      ev.hours.should == 22 
      ev.creator.should == users(:worker)
    end

  end

  describe 'the create' do

    it 'should automatically set revised hours' do
      s = Story.new :estimated_hours => 8
      s.valid?    
      s.revised_hours.should == 8
    end

  end

  describe 'the class' do
    
    it 'should find active stories' do
      Story.active.all(:order => 'title').should == stories(:active, :almost_complete)      
    end
    
  end
  
end

