class StructuralDatabaseChanges01 < ActiveRecord::Migration
  def self.up
    change_column :milestones, :rank, :integer, :default => 9999
    change_column :priorities, :rank, :integer, :default => 9999
    change_column :status, :rank, :integer, :default => 9999
    change_column :ticket_reports, :rank, :integer, :default => 9999    
    
    change_column :changes, :repository_id, :integer, :default => nil
    add_index :changes, :repository_id
  end

  def self.down
    remove_index :changes, :repository_id
  end
end
