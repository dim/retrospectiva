class AddExistingTicketsCacheToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :existing_tickets, :text
  end

  def self.down
    remove_column :projects, :existing_tickets
  end
end
