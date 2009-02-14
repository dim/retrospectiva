class ChangeGroupAccessToAllProjectsBehaviour < ActiveRecord::Migration
  def self.up
    project_ids = select_all("SELECT id FROM projects").map {|i| i['id'] }    
    select_all("SELECT id FROM groups WHERE access_to_all_projects = #{quoted_true}").each do |record|
      project_ids.each do |project_id|
        execute "INSERT INTO groups_projects (group_id, project_id) VALUES (#{record['id']}, #{project_id})"
      end
    end
  end

  def self.down
  end
end
