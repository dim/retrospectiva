class VerifyStateIdInStatus < ActiveRecord::Migration
  def self.up
    Status.set_table_name('status')
    Status.update_all('state_id = 1', ['state_id IS NULL AND default_value = ?', true])
    Status.update_all('state_id = 3', ['state_id IS NULL AND default_value = ?', false])
  end

  def self.down
  end
end
