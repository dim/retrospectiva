class AddTypeToAttachments < ActiveRecord::Migration
  def self.up
    add_column :attachments, :type, :string, :limit => 20
    add_index :attachments, :type, :name => 'i_attachments_type'
    execute "UPDATE attachments SET type = 'Attachment' WHERE type IS NULL"
  end

  def self.down
    remove_column :attachments, :type 
  end
end
