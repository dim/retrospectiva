class ChangeGroupAccessToAllProjectsBehaviour < ActiveRecord::Migration
  def self.up
    Group.find_all_by_access_to_all_projects(true).each do |group|
      group.projects = Project.find(:all)
      group.save
    end
  end

  def self.down
  end
end
