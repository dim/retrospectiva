class CreateStoryProgressUpdates < ActiveRecord::Migration

  def self.up
    create_table 'story_progress_updates' do |t|
      t.integer  'story_id'
      t.integer  'percent_completed', :limit => 3
      t.date     'created_on'
    end          
    add_index 'story_progress_updates', 'story_id', :name => "i_storypgu_on_story_id"
    add_index 'story_progress_updates', 'percent_completed', :name => "i_storypgu_on_pc_cpld"
    add_index 'story_progress_updates', 'created_on', :name => "i_storypgu_on_created_on"
  end

  def self.down
    remove_index 'story_progress_updates', :name => "i_storypgu_on_story_id"
    remove_index 'story_progress_updates', :name => "i_storypgu_on_pc_cpld"
    remove_index 'story_progress_updates', :name => "i_storypgu_on_created_on"
    drop_table 'story_progress_updates'
  end
end
