class RenameOriginalFileNameAndAddCreatedAtToAttachments < ActiveRecord::Migration
  def self.up
    rename_column :attachments, :original_filename, :file_name
    add_column :attachments, :created_at, :datetime
  end

  def self.down
    rename_column :attachments, :file_name, :original_filename
    remove_column :attachments, :created_at
  end
end
