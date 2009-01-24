class RenameTicketChangesChangesToUpdates < ActiveRecord::Migration
  def self.up
    rename_column :ticket_changes, :changes, :updates
  end

  def self.down
    rename_column :ticket_changes, :updates, :changes
  end
end
