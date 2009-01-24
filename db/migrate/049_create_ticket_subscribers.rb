class CreateTicketSubscribers < ActiveRecord::Migration
  def self.up
    create_table(:ticket_subscribers, :id => false) do |t|
      t.column :ticket_id, :integer
      t.column :user_id, :integer
    end
    
    add_index :ticket_subscribers, :ticket_id
    add_index :ticket_subscribers, :user_id    
  end

  def self.down
    drop_table :ticket_subscribers
  end
end
