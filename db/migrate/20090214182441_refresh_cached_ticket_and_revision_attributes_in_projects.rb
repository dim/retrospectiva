class RefreshCachedTicketAndRevisionAttributesInProjects < ActiveRecord::Migration
  def self.up
    Project.all.each do |project|
      project.reset_existing_tickets!
      project.reset_existing_revisions!
    end rescue true
  end

  def self.down
  end
end
