class AddCreatedAtAndDeliveredToQueuedMails < ActiveRecord::Migration
  def self.up
    add_column :queued_mails, :created_at, :datetime
    add_column :queued_mails, :delivered_at, :datetime
  end

  def self.down
    remove_column :queued_mails, :created_at
    remove_column :queued_mails, :delivered_at
  end
end
