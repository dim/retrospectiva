class TidyUpPreviousMigrations < ActiveRecord::Migration
  def self.up
    change_column :statuses, :state_id, :integer, :limit => 2
    change_column :changes, :path, :string
    change_column :changes, :from_path, :string
    change_column_default :changes, :path, nil 
    change_column :ticket_reports, :rank, :integer, :null => false    
    change_column :users, :scm_name, :string, :limit => 80
  end

  def self.down
  end
end
