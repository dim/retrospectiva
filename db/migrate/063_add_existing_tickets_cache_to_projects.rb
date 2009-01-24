class AddExistingTicketsCacheToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :existing_tickets, :text
    Status.set_table_name('statuses')
    Project.find(:all).each do |project|
      ticket_cache = project.tickets.inject({}) do |result, ticket|
        result[ticket.id] = {:state => ticket.state.id, :summary => ticket.summary}
        result
      end
      project.update_attribute(:existing_tickets, ticket_cache)
    end
  end

  def self.down
    remove_column :projects, :existing_tickets
  end
end
