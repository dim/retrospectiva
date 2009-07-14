Project.class_eval do

  has_many :wiki_pages, :dependent => :destroy do
    
    def find_or_build(title)
      record = find_by_title(title)
      unless record
        record = build
        record.title = title
      end
      record
    end
    
  end
  
  has_many :wiki_files, :dependent => :destroy do
    
    def find_readable(title)
      file = find_by_wiki_title(title)
      file and file.readable? ? file : nil
    end

    def find_readable_image(title)
      file = find_readable(title)
      file and file.image? ? file : nil
    end
    
  end
          
  serialize :existing_wiki_page_titles, Array
  before_update :update_main_wiki_page_title
  
  def wiki_title(name = self.name)
    name.gsub(/[\.\?\/;,]/, '-').gsub(/-{2,}/, '-')
  end

  def existing_wiki_page_titles
    value = read_attribute(:existing_wiki_page_titles)
    value.is_a?(Array) ? value : []
  end

  def reset_existing_wiki_page_titles!
    update_attribute :existing_wiki_page_titles, wiki_pages.map(&:title)
  end

  protected
    
    def update_main_wiki_page_title
      if name_changed?
        page = wiki_pages.find_by_title(wiki_title(name_was))
        page.update_attribute(:title, wiki_title) if page
      end
      true
    end

end
