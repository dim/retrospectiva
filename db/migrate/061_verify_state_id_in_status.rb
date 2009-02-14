class VerifyStateIdInStatus < ActiveRecord::Migration
  def self.up
    execute "UPDATE status SET state_id = 1 WHERE state_id IS NULL AND default_value = #{quoted_true}"
    execute "UPDATE status SET state_id = 3 WHERE state_id IS NULL AND default_value = #{quoted_false}"
  end

  def self.down
  end
end
