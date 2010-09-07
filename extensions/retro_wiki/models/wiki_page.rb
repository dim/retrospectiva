#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class WikiPage < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  has_many :versions, 
    :class_name => 'WikiVersion',
    :order => 'wiki_versions.created_at', 
    :dependent => :destroy

  validates_length_of :title, :in => 2..80
  validates_format_of :title, :with => /\A\w[^\.\?\/;,]{1,}\Z/
  validates_presence_of :content
  validates_presence_of :author
  validates_uniqueness_of :title, :case_sensitive => false, :scope => :project_id
  validates_association_of :project

  attr_accessible :content, :author

  retro_previewable do |r|
    r.channel do |c, options|
      project = options[:project] || Project.current
      c.name = 'wiki'
      c.title = _('Wiki')
      c.description = _('Wiki for %{project}', :project => project.name)
      c.link = c.route(:project_wiki_pages_url, project)
    end
    r.item do |i, wiki_page, options|
      project = options[:project] || Project.current
      i.title = wiki_page.title
      i.description = wiki_page.content
      i.date = wiki_page.updated_at
      i.link = i.guid = i.route(:project_wiki_page_url, project, wiki_page)
    end
  end  
  
  named_scope :feedable, :order => 'wiki_pages.created_at DESC', :limit => 10

  class << self
    
    def searchable_column_names
      [ 'wiki_pages.title', 'wiki_pages.content' ]
    end
    
    def full_text_search(query)
      find :all,
        :conditions => Retro::Search::exclusive(query, *searchable_column_names),
        :limit => 100,
        :order => 'wiki_pages.updated_at DESC'      
    end
        
  end
  
  def to_param
    title
  end

  def number
    @number ||= versions.size + 1
  end
  alias_method :version, :number

  def newer_versions
    0
  end

  def older_versions
    versions.size
  end

  def historic?
    false
  end

  def serialize_only
    [:author, :title, :content, :created_at, :updated_at]
  end

  def serialize_methods
    [:version]
  end
  
  def find_version(num)
    num = num.to_i

    if num == version
      self
    elsif num > 0
      versions[num - 1]
    else
      nil
    end
  end
  
  protected

    def before_validation
      unless User.current.public?
        self.user = User.current
      end

      if user.present?
        self.author = user.name
      end

      true
    end

    def validate_on_update
      errors.add_to_base _('Nothing changed') unless content_changed? || title_changed?
      errors.empty?
    end
    
    def before_update
      if content_changed?
        versions.build :author => author_was, :content => content_was, :user_id => user_id_was, :created_at => updated_at_was
      end
      true
    end

    def after_create
      name_cache = project.existing_wiki_page_titles + [ title ]
      project.update_attribute :existing_wiki_page_titles, name_cache.uniq
    end
    
    def after_update
      if title_changed?
        name_cache = project.existing_wiki_page_titles + [ title ] - [ title_was ]
        project.update_attribute :existing_wiki_page_titles, name_cache.uniq
      end
      true
    end

    def before_destroy
      name_cache = project.existing_wiki_page_titles - [ title ]
      project.update_attribute :existing_wiki_page_titles, name_cache.uniq
    end

end
