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
    @milestone.tickets.should have(5).records
  end

  it "should belong to a project" do
    @milestone.should belong_to(:project)
  end

  describe 'counting tickets (when tickets are not pre-loaded)' do
    it "should count total tickets" do
      @milestone.total_tickets.should == 5
    end

    it "should count total tickets" do
      @milestone.total_tickets.should == 5
    end

    it "should count tickets by state" do
      @milestone.ticket_counts.should == { 'open' => 3, 'in_progress' => 1, 'resolved' => 1 }
    end

    it "should count progress percentages" do
      @milestone.progress_percentages.should == { 'open' => 60, 'in_progress' => 20, 'resolved' => 20 }
    end
  end

  describe 'counting tickets (when tickets are pre-loaded)' do
    before do
      @milestone.tickets(true)
    end

    it "should count total tickets" do
      @milestone.total_tickets.should == 5
    end

    it "should count tickets by state" do
      @milestone.ticket_counts.should == { 'open' => 3, 'in_progress' => 1, 'resolved' => 1 }
    end

    it "should count progress percentages" do
      @milestone.progress_percentages.should == { 'open' => 60, 'in_progress' => 20, 'resolved' => 20 }
    end
  end

  describe 'progress percentage rounding' do
   
    def test_with(open, in_progress, resolved)
      counts = {'open' => open, 'in_progress' => in_progress, 'resolved' => resolved}.with_indifferent_access
      @milestone.stub!(:ticket_counts).and_return(counts)
      @milestone.stub!(:total_tickets).and_return(counts.values.sum)
      @milestone.progress_percentages.values.sum.should == 100
      @milestone.progress_percentages
    end
   
    it 'should round correctly' do
      test_with(0, 21, 3).should   == { 'open' => 0,   'in_progress' => 87, 'resolved' => 13 }
    end   

    it 'should round correctly' do
      test_with(33, 33, 33).should == { 'open' => 34,  'in_progress' => 33, 'resolved' => 33 }
    end   

    it 'should round correctly' do
      test_with(1, 1, 56).should   == { 'open' => 1,   'in_progress' => 2,  'resolved' => 97 }
    end   

    it 'should round correctly' do
      test_with(0, 0, 0).should    == { 'open' => 100, 'in_progress' => 0,  'resolved' => 0  }
    end   

  end
end
