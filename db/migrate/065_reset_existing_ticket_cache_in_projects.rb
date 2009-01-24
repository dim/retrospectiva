class ResetExistingTicketCacheInProjects < ActiveRecord::Migration
  def self.up
    Project.find(:all).each do |project|
      ticket_cache = project.tickets.inject({}) do |result, ticket|
        result[ticket.id] = {:state => ticket.state.id, :summary => ticket.summary}
        result
      end
      project.update_attribute(:existing_tickets, ticket_cache)
    end
  end

  def self.down
  end
end
