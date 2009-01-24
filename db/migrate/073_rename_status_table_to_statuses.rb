class RenameStatusTableToStatuses < ActiveRecord::Migration
  def self.up
    rename_table :status, :statuses
  end

  def self.down
    rename_table :statuses, :status
  end
end
