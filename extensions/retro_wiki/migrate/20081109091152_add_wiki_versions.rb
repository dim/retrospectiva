class AddWikiVersions < ActiveRecord::Migration
  def self.up
    
    if tables.include?('wiki_versions')
      index_names = indexes('wiki_versions').map(&:name)
      
      if index_names.include?('i_wiki_pages_on_project_id')
        remove_index 'wiki_versions', :name => "i_wversions_on_project_id"
      end
  
      unless index_names.include?('i_wversions_on_wpage_id')
        add_index 'wiki_versions', 'wiki_page_id', :name => "i_wversions_on_wpage_id"
      end
  
      unless index_names.include?('i_wversions_on_user_id')
        add_index 'wiki_versions', 'user_id', :name => "i_wversions_on_user_id"
      end

      col_names = columns('wiki_versions').map(&:name)
      if col_names.include?('project_id')
        remove_column 'wiki_versions', 'project_id'
      end
      
    else
      create_table 'wiki_versions' do |t|
        t.column 'wiki_page_id',     :integer
        t.column 'author',           :string
        t.column 'user_id',          :integer
        t.column 'created_at',       :datetime
        t.column 'content',          :text
      end

      add_index 'wiki_versions', 'wiki_page_id', :name => "i_wversions_on_wpage_id"
      add_index 'wiki_versions', 'user_id', :name => "i_wversions_on_user_id"
    end    
  end

  def self.down
    drop_table 'wiki_versions'
  end

end
