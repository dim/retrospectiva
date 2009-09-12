class CreateGoals < ActiveRecord::Migration

  def self.up
    create_table 'goals' do |t|
      t.string  'title', :limit => 160
      t.text    'description'
      t.integer 'priority_id', :limit => 2, :default => 3, :null => false
      t.integer 'sprint_id'
      t.integer 'milestone_id'
      t.integer 'requester_id'
      t.timestamps
    end          
    add_index 'goals', 'sprint_id', :name => "i_goals_on_sprint_id"
    add_index 'goals', 'milestone_id', :name => "i_goals_on_mstone_id"
    add_index 'goals', 'requester_id', :name => "i_goals_on_rster_id"    
    add_index 'goals', 'priority_id', :name => "i_goals_on_prioty_id"    
  end

  def self.down
    remove_index 'goals', :name => "i_goals_on_sprint_id"    
    remove_index 'goals', :name => "i_goals_on_mstone_id"
    remove_index 'goals', :name => "i_goals_on_rster_id"
    remove_index 'goals', :name => "i_goals_on_prioty_id"
    drop_table 'goals'
  end
end
