class AddWikiTitleToAttachments < ActiveRecord::Migration
  def self.up
    add_column :attachments, :wiki_title, :string, :limit => 80
  end

  def self.down
    remove_column :attachments, :wiki_title
  end
end
