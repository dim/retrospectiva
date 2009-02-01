require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Milestone do
  fixtures :milestones, :tickets, :projects, :statuses
  
  describe 'the class' do

    it 'should return (by default) up to 5 records per page' do
      Milestone.per_page.should == 5
    end    

    describe 'full text search' do      
      
      it 'should find records matching the milestone name and description' do
        Milestone.full_text_search('info').should have(4).records
        Milestone.full_text_search('unscheduled').should have(1).record
      end      
    
    end

    describe 'previewable' do
      
      describe 'channel' do
        before do
          @channel = Milestone.previewable.channel(:project => projects(:retro))
        end
        
        it 'should have a valid name' do
          @channel.name.should == 'milestones'
        end
        
        it 'should have a valid title' do
          @channel.title.should == 'Milestones'
        end
        
        it 'should have a valid description' do
          @channel.description.should == 'Milestones for Retrospectiva'
        end
        
        it 'should have a valid link' do
          @channel.link.should == 'http://test.host/projects/retrospectiva/milestones'
        end      

      end

      describe 'items' do
        
        before do
          @milestone = milestones(:retro_unscheduled)
          @item = @milestone.previewable(:project => projects(:retro))
        end
        
        it 'should have a valid title' do
          @item.title.should == 'Milestone: ' + @milestone.name
        end
        
        it 'should have a valid description' do
          @item.description.should == @milestone.info
        end
        
        it 'should have a valid link' do
          @item.link.should == "http://test.host/projects/retrospectiva/milestones"
        end
        
        it 'should have a date' do
          @item.date.should == @milestone.updated_at
        end      
        
      end

    end   
  end
  
    
  before(:each) do
    @milestone = milestones(:retro_next_release)
  end

  it "should validate presence name" do
    @milestone.should validate_presence_of(:name)
  end

  it "should validate uniqueness name within a project" do
    @milestone.should validate_uniqueness_of(:name)
  end

  it "should validate presence of project" do
    @milestone.should validate_presence_of(:project_id)
  end

  it "should validate presence of start-date" do
    @milestone.stub!(:started_on).and_return(nil)
    @milestone.should validate_presence_of(:started_on)
  end

  it 'should have a completed indicator' do
    @milestone.completed?.should be(false)
    milestones(:retro_completed).completed?.should be(true)
  end

  it "should set started-on to today by default" do
    Milestone.new.started_on.should == Date.today
  end

  it "should have many tickets" do
    @milestone.should have_many(:tickets)
    @milestone.tickets.should have(4).records
  end

  it "should belong to a project" do
    @milestone.should belong_to(:project)
  end

  describe 'counting tickets (when tickets are not pre-loaded)' do
    it "should count total tickets" do
      @milestone.total_tickets.should == 4
    end

    it "should count open tickets" do
      @milestone.open_tickets.should == 3
    end

    it "should count closed tickets" do
      @milestone.closed_tickets.should == 1
    end

    it "should count the progress as open-to-closed ticket ratio" do
      @milestone.percent_completed.should == 25
    end
  end

  describe 'counting tickets (when tickets are pre-loaded)' do
    before do
      @milestone.tickets(true)
    end
    
    it "should count total tickets" do
      @milestone.total_tickets.should == 4
    end

    it "should count open tickets" do
      @milestone.open_tickets.should == 3
    end

    it "should count closed tickets" do
      @milestone.closed_tickets.should == 1
    end

    it "should count the progress as open-to-closed ticket ratio" do
      @milestone.percent_completed.should == 25
    end
  end

end
