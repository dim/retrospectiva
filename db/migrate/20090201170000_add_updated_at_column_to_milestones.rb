class AddUpdatedAtColumnToMilestones < ActiveRecord::Migration
  def self.up
    add_column :milestones, :updated_at, :datetime
    add_index :milestones, :updated_at, :name => 'i_mst_on_updated_at'
    execute "UPDATE milestones SET updated_at = created_at"
  end

  def self.down
    remove_index :milestones, :name => 'i_mst_on_updated_at'
    remove_column :milestones, :updated_at, :datetime
  end
end
