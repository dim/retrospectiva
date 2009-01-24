class AddExistingRevisionsCacheToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :existing_revisions, :text
    Project.find(:all).each do |project|
      project.update_existing_revisions
    end
  end

  def self.down
    remove_column :projects, :existing_revisions
  end
end
