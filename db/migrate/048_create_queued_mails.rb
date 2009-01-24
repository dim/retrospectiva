class CreateQueuedMails < ActiveRecord::Migration
  def self.up
    create_table :queued_mails do |t|
      t.column :object,            :text
      t.column :mailer_class_name, :string
    end
  end
  
  def self.down
    drop_table :queued_mails
  end
end
