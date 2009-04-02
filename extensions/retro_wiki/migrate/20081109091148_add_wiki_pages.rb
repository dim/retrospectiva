class AddWikiPages < ActiveRecord::Migration
  def self.up
    
    latest_versions = if tables.include?('wiki_versions')
      suppress_messages do
        select_all "
          SELECT wiki_versions.id, wiki_versions.wiki_page_id, wiki_versions.author, wiki_versions.user_id, wiki_versions.content
          FROM wiki_versions
          INNER JOIN (
            SELECT wiki_page_id, MAX(created_at) AS created_at FROM wiki_versions GROUP BY wiki_page_id
          ) latest_versions 
            ON latest_versions.wiki_page_id = wiki_versions.wiki_page_id 
           AND latest_versions.created_at = wiki_versions.created_at      
        "
      end
    else
      []
    end
    
    if tables.include?('wiki_pages')
      col_names = columns('wiki_pages').map(&:name)
      unless col_names.include?('author')
        add_column 'wiki_pages', 'author', :string
        suppress_messages do
          latest_versions.each do |version|
            execute "UPDATE wiki_pages SET author = #{quote(version['author'])} WHERE id = #{version['wiki_page_id']}"
          end
        end
      end
      unless col_names.include?('user_id')
        add_column 'wiki_pages', 'user_id', :integer
        suppress_messages do
          latest_versions.each do |version|
            execute "UPDATE wiki_pages SET user_id #{version['user_id'].blank? ? 'NULL' : '= ' + version['user_id']} WHERE id = #{version['wiki_page_id']}"
          end
        end
      end
      unless col_names.include?('content')
        add_column 'wiki_pages', 'content', :text
        suppress_messages do
          latest_versions.each do |version|
            execute "UPDATE wiki_pages SET content = #{quote(version['content'])} WHERE id = #{version['wiki_page_id']}"
          end
        end
      end
      
      index_names = indexes('wiki_pages').map(&:name)
      unless index_names.include?('i_wiki_pages_on_title')
        add_index :wiki_pages, :title, :name => "i_wiki_pages_on_title"
      end
      unless index_names.include?('i_wiki_pages_on_project_id')
        add_index :wiki_pages, :project_id, :name => "i_wiki_pages_on_project_id"
      end
      unless index_names.include?('i_wiki_pages_on_user_id')
        add_index :wiki_pages, :user_id, :name => "i_wiki_pages_on_user_id"
      end
      
    else
      
      create_table 'wiki_pages' do |t|
        t.column 'title',      :string
        t.column 'project_id', :integer
        t.column 'created_at', :datetime
        t.column 'updated_at', :datetime
        t.column 'author',     :string
        t.column 'user_id',    :integer
        t.column 'content',    :text
      end

      add_index :wiki_pages, :title, :name => "i_wiki_pages_on_title"
      add_index :wiki_pages, :project_id, :name => "i_wiki_pages_on_project_id"
      add_index :wiki_pages, :user_id, :name => "i_wiki_pages_on_user_id"
    end    

    unless columns('projects').map(&:name).include?('existing_wiki_page_titles')
      add_column 'projects', 'existing_wiki_page_titles', :text, :limit => (16.megabytes - 1)
    end

    suppress_messages do
      change_column 'projects', 'existing_wiki_page_titles', :text, :limit => (16.megabytes - 1)
      select_all("SELECT title, project_id FROM wiki_pages").group_by do |record|
        record['project_id']
      end      
    end.each do |project_id, records|
      titles = records.map {|i| i['title'] }.to_yaml
      execute "UPDATE projects SET existing_wiki_page_titles = #{quote(titles)} WHERE id = #{project_id}" 
    end
    
  end

  def self.down
    remove_column :projects, 'existing_wiki_page_titles'
    drop_table 'wiki_pages'
  end
end
