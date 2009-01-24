class AddStartedOnToMilestones < ActiveRecord::Migration
  def self.up
    add_column :milestones, :started_on, :date
    execute "UPDATE milestones SET started_on = created_at WHERE started_on IS NULL"
  end

  def self.down
    remove_column :milestones, :started_on
  end
end
