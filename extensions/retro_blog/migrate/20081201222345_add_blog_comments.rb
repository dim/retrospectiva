class AddBlogComments < ActiveRecord::Migration

  def self.up    
    if tables.include?('blog_comments') # Migrate
      
      existing_columns, existing_indexes = [], []
      suppress_messages do
        existing_columns = columns('blog_comments').map(&:name)
        existing_indexes = indexes('blog_comments').map(&:name)
      end

      if existing_columns.include?('spam')
        remove_column 'blog_comments', 'spam'    
      end

      if existing_columns.include?('approved')
        remove_column 'blog_comments', 'approved'    
      end

      if existing_indexes.include?('i_bposts_on_bpost_id')      
        remove_index "blog_comments", :name => "i_bposts_on_bpost_id"
      end
      
      unless existing_indexes.include?('i_bcomments_on_bpost_id')
        add_index "blog_comments", ["blog_post_id"], :name => "i_bcomments_on_bpost_id"
      end
      
    else # Create
    
      create_table 'blog_comments' do |t|
        t.column 'blog_post_id',    :integer
        t.column 'author',           :string
        t.column 'email',            :string
        t.column 'content',          :text
        t.column 'created_at',       :datetime
      end
      add_index "blog_comments", ["blog_post_id"], :name => "i_bcomments_on_bpost_id"
      
    end
  end

  def self.down
    drop_table 'blog_comments'
  end
end
