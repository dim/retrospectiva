class MakeTagStorageMoreEfficient < ActiveRecord::Migration
  def self.up
    change_column :taggings, :taggable_type, :string, :limit => 30  
    change_column :taggings, :tagger_type, :string, :limit => 30  
    change_column :taggings, :context, :string, :limit => 30
  end

  def self.down
    change_column :taggings, :taggable_type, :string 
    change_column :taggings, :tagger_type, :string
    change_column :taggings, :context, :string
  end
end
