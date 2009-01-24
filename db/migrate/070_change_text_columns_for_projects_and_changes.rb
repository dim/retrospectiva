class ChangeTextColumnsForProjectsAndChanges < ActiveRecord::Migration
  def self.up
    change_column :changes, :path, :string, :limit => 255
    change_column :changes, :from_path, :string, :limit => 255
    change_column :projects, :root_path, :string, :limit => 255
  end

  def self.down
  end
end

