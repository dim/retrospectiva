class MakeAttachmentStorageMoreEfficient < ActiveRecord::Migration
  def self.up
    change_column :attachments, :file_name, :string, :null => true
    change_column_default :attachments, :file_name, nil

    change_column :attachments, :content_type, :string, :null => true
    change_column_default :attachments, :content_type, nil
    
    change_column :attachments, :attachable_type, :string, :null => true, :limit => 30
    change_column_default :attachments, :attachable_type, nil

    change_column :attachments, :attachable_id, :integer, :null => true
    change_column_default :attachments, :attachable_id, nil
  end

  def self.down
    change_column :attachments, :file_name, :string, :null => false
    change_column_default :attachments, :file_name, ''

    change_column :attachments, :content_type, :string, :null => false
    change_column_default :attachments, :content_type, ''
    
    change_column :attachments, :attachable_type, :string, :null => false
    change_column_default :attachments, :attachable_type, ''

    change_column :attachments, :attachable_id, :integer, :null => false
    change_column_default :attachments, :attachable_id, 0
  end
end
