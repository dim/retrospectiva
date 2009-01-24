class AddWikiTitleIndexToAttachments < ActiveRecord::Migration
  def self.up
    add_index :attachments, :wiki_title, :name => 'i_attachments_wk_title'
  end

  def self.down
    remove_index :attachments, :name => 'i_attachments_wk_title'
  end
end
