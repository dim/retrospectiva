class AddStatementIdToStatus < ActiveRecord::Migration
  def self.up
    add_column :statuses, :statement_id, :integer, :limit => 2
    execute "UPDATE statuses SET statement_id = 2 WHERE statement_id IS NULL"
  end

  def self.down
    remove_column :statuses, :statement_id
  end
end
