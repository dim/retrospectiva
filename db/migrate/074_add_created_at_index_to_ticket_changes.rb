class AddCreatedAtIndexToTicketChanges < ActiveRecord::Migration
  def self.up
    add_index "ticket_changes", ["created_at"], :name => "i_tchanges_on_created_at"
  end

  def self.down
    remove_index "ticket_changes", :name => "i_tchanges_on_created_at"
  end
end
