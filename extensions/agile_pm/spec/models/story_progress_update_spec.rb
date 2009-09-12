require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe StoryProgressUpdate do
  fixtures :stories, :story_progress_updates
  
  it 'should belong to story' do
    story_progress_updates(:active_50).should belong_to(:story)
  end
  
  it 'should validate presence of story' do    
    story_progress_updates(:active_50).should validate_association_of(:story)
  end

  it 'should validate correctness of percent-completed' do    
    story_progress_updates(:active_50).percent_completed = 25
    story_progress_updates(:active_50).should have(1).error_on(:percent_completed)

    story_progress_updates(:active_50).percent_completed = 50
    story_progress_updates(:active_50).should have(:no).error_on(:percent_completed)
  end
  
  it 'should not allow multiple records for a story for the same day' do
    s = StoryProgressUpdate.new :story_id => story_progress_updates(:active_50).story_id,
      :created_on => story_progress_updates(:active_50).created_on,
      :percent_completed => 100
    s.should have(1).error_on(:created_on)
  end
  
end

