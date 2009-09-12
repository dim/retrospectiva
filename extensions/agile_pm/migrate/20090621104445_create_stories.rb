class CreateStories < ActiveRecord::Migration

  def self.up
    create_table 'stories' do |t|
      t.string   'title', :limit => 160
      t.text     'description'
      t.integer  'sprint_id'
      t.integer  'goal_id'
      t.integer  'created_by'
      t.integer  'assigned_to'
      t.integer  'estimated_hours', :null => false, :default => 0
      t.integer  'revised_hours', :null => false, :default => 0
      t.datetime 'started_at'
      t.datetime 'completed_at'
      t.timestamps
    end          
    add_index 'stories', 'sprint_id', :name => "i_stories_on_sprint_id"
    add_index 'stories', 'goal_id', :name => "i_stories_on_goal_id"
    add_index 'stories', 'created_by', :name => "i_stories_on_created_by"
    add_index 'stories', 'assigned_to', :name => "i_stories_on_asngd_to"
  end

  def self.down
    remove_index 'stories', :name => "i_stories_on_sprint_id"    
    remove_index 'stories', :name => "i_stories_on_goal_id"
    remove_index 'stories', :name => "i_stories_on_created_by"
    remove_index 'stories', :name => "i_stories_on_asngd_to"
    drop_table 'stories'
  end
end
