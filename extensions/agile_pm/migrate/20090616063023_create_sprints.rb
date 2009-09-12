class CreateSprints < ActiveRecord::Migration

  def self.up
    create_table 'sprints' do |t|
      t.string  'title'
      t.date 'starts_on'
      t.date 'finishes_on'
      t.integer 'milestone_id'
      t.timestamps
    end          
    add_index 'sprints', 'starts_on', :name => "i_sprints_on_start"
    add_index 'sprints', 'finishes_on', :name => "i_sprints_on_finish"
    add_index 'sprints', 'milestone_id', :name => "i_sprints_on_mstone_id"    
  end

  def self.down
    remove_index 'sprints', :name => "i_sprints_on_mstone_id"
    remove_index 'sprints', :name => "i_sprints_on_start"
    remove_index 'sprints', :name => "i_sprints_on_finish"
    drop_table 'sprints'
  end
end
