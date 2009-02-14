class AddStatesToStatus < ActiveRecord::Migration
  def self.up
    add_column :status, :state_id, :integer, :limit => 1
    execute "UPDATE status SET state_id = 1 WHERE state_id IS NULL AND default_value = #{quoted_true}"
    execute "UPDATE status SET state_id = 3 WHERE state_id IS NULL AND default_value = #{quoted_false}"
  end

  def self.down
    remove_column :status, :state_id
  end
end
