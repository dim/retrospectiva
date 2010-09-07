require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MilestonesHelper do
  
  #Delete this example and add some real ones or delete this file
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(MilestonesHelper)
  end
  
  describe 'ticket stats and links' do
    
    before do
      @project = stub_current_project! :to_param => 'retro'
      @milestone = mock_model Milestone,      
        :id => '1',
        :ticket_counts => { 'open' => 10, 'in_progress' => 0, 'resolved' => 90 }.with_indifferent_access
    end
    
    it 'should produce expected output' do
      helper.ticket_stats_and_links(@milestone).should == [ 
        "<a href=\"/projects/retro/tickets?milestone=1&amp;state=3\">Resolved (90)</a>",
        "<a href=\"/projects/retro/tickets?milestone=1&amp;state=1\">Open (10)</a>"
      ].join(', ')
    end
    
  end

  describe 'progress bars' do
    
    before do
      helper.stub!(:image_spacer).and_return('I')
      @project = stub_current_project!
      @milestone = mock_model Milestone, 
        :progress_percentages => { 'open' => 80, 'in_progress' => 20, 'resolved' => 0 }.with_indifferent_access
    end
    
    it 'should produce expected output' do
      helper.progress_bars(@milestone).should == [
        "<div class=\"in-progress\" style=\"width:20%;\">I</div>",
        "<div class=\"open\" style=\"width:80%;\">I</div>"
      ].join
    end
    
  end
  
end
