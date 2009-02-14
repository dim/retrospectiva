class AddRankingToStaticTicketProperties < ActiveRecord::Migration
  def self.up
    add_column :status, :rank, :integer
    add_index :status, :rank

    remove_column :priorities, :position
    add_column :priorities, :rank, :integer
    add_index :priorities, :rank

    add_column :milestones, :rank, :integer
    add_index :milestones, :rank
    
    execute "UPDATE status SET rank = id"
    execute "UPDATE priorities SET rank = id"
    execute "UPDATE milestones SET rank = id"

    rename_column :ticket_reports, :position, :rank
  end

  def self.down
    remove_index :status, :rank
    remove_column :status, :rank

    remove_index :priorities, :rank
    remove_column :priorities, :rank
    add_column :priorities, :position, :integer

    remove_index :milestones, :rank
    remove_column :milestones, :rank

    rename_column :ticket_reports, :rank, :position
  end
end
