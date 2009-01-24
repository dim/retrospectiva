class AddBlogPosts < ActiveRecord::Migration
  def self.up
    
    if tables.include?('blog_posts') # Migrate
      
      existing_columns, existing_indexes = [], []
      suppress_messages do
        existing_columns = columns('blog_posts').map(&:name)
        existing_indexes = indexes('blog_posts').map(&:name)
      end

      if existing_columns.include?('blog_comments_count')
        remove_column 'blog_posts', 'blog_comments_count'    
      end
      
      unless existing_indexes.include?('i_bposts_on_project_id')
        add_index "blog_posts", ["project_id"], :name => "i_bposts_on_project_id"
      end

      unless existing_indexes.include?('i_bposts_on_user_id')      
        add_index "blog_posts", ["user_id"], :name => "i_bposts_on_user_id"
      end
      
    else # Create
    
      create_table 'blog_posts' do |t|
        t.column 'title',      :string
        t.column 'content',    :text
        t.column 'user_id',    :integer
        t.column 'project_id', :integer
        t.column 'created_at', :datetime
        t.column 'updated_at', :datetime
      end

      add_index "blog_posts", ["project_id"], :name => "i_bposts_on_project_id"
      add_index "blog_posts", ["user_id"], :name => "i_bposts_on_user_id"
      
    end

  end

  def self.down
    drop_table 'blog_posts'
  end

end
