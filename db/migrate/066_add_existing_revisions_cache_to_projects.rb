class AddExistingRevisionsCacheToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :existing_revisions, :text
    Project.find(:all).each(&:reset_existing_tickets!) rescue true
  end

  def self.down
    remove_column :projects, :existing_revisions
  end
end
