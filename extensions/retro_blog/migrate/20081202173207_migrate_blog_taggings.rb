class MigrateBlogTaggings < ActiveRecord::Migration

  def self.up
    execute "UPDATE taggings SET context = 'categories' WHERE taggable_type = 'BlogPost' AND context IS NULL"
  end

  def self.down
  end
end
