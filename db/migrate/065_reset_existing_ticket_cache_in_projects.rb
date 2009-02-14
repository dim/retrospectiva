class ResetExistingTicketCacheInProjects < ActiveRecord::Migration
  def self.up
    Project.find(:all).each(&:reset_existing_tickets!) rescue true
  end

  def self.down
  end
end
