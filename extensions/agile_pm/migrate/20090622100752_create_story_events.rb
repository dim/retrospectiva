class CreateStoryEvents < ActiveRecord::Migration

  def self.up
    create_table 'story_events' do |t|
      t.integer  'story_id'
      t.string   'type', :limit => 20
      t.text     'content'
      t.integer  'hours'
      t.integer  'created_by'
      t.datetime 'created_at'
    end          
    add_index 'story_events', 'type', :name => "i_storyevt_on_type"
    add_index 'story_events', 'story_id', :name => "i_storyevt_on_story_id"
    add_index 'story_events', 'created_at', :name => "i_storyevt_on_created_at"
    add_index 'story_events', 'created_by', :name => "i_storyevt_on_created_by"
  end

  def self.down
    remove_index 'story_events', :name => "i_storyevt_on_type"
    remove_index 'story_events', :name => "i_storyevt_on_story_id"
    remove_index 'story_events', :name => "i_storyevt_on_created_at"
    remove_index 'story_events', :name => "i_storyevt_on_created_by"
    drop_table 'story_events'
  end
end
