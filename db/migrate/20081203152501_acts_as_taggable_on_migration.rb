class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    add_column :taggings, :tagger_id, :integer 
    add_column :taggings, :tagger_type, :string 
    add_column :taggings, :context, :string 
    add_column :taggings, :created_at, :datetime 

    remove_index "taggings", :name => "i_taggings_on_references"
    add_index :taggings, :tag_id, :name => "i_taggings_on_tag_id"
    add_index :taggings, [:taggable_id, :taggable_type, :context], :name => "i_taggings_on_references"
  end
  
  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
