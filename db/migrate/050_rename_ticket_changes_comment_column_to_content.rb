class RenameTicketChangesCommentColumnToContent < ActiveRecord::Migration
  def self.up
    rename_column :ticket_changes, :comment, :content
  end

  def self.down
    rename_column :ticket_changes, :content, :comment
  end
end
