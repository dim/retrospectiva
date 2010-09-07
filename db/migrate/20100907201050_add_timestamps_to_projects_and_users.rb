class AddTimestampsToProjectsAndUsers < ActiveRecord::Migration
  def self.up
    add_column :projects, :created_at, :timestamp
    add_column :projects, :updated_at, :timestamp
    add_column :users, :updated_at, :timestamp
    
    rows = select_all %(
      SELECT projects.id, MIN(LEAST(tickets.created_at, milestones.created_at)) AS created_at 
      FROM projects 
      INNER JOIN tickets ON tickets.project_id = projects.id    
      INNER JOIN milestones ON milestones.project_id = projects.id
      WHERE projects.created_at IS NULL
      GROUP BY projects.id
    )  
    rows.each do |row|
      update "UPDATE projects SET created_at = #{quote(row['created_at'])} WHERE id = #{row['id']}"           
    end
    
    update "UPDATE projects SET created_at = #{quote(Time.now.utc.to_s(:db))} WHERE created_at IS NULL"
    update "UPDATE projects SET updated_at = #{quote(Time.now.utc.to_s(:db))} WHERE updated_at IS NULL"
    update "UPDATE users SET updated_at = #{quote(Time.now.utc.to_s(:db))} WHERE updated_at IS NULL"
  end

  def self.down    
    remove_column :projects, :created_at
    remove_column :projects, :updated_at
    remove_column :users, :updated_at
  end
end
