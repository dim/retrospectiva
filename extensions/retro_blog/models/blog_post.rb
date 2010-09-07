#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class BlogPost < ActiveRecord::Base
  acts_as_taggable_on :categories
  
  belongs_to :project
  belongs_to :user
  has_many :comments,
    :class_name => 'BlogComment',
    :order => 'blog_comments.created_at', 
    :dependent => :destroy

  validates_association_of :user, :project
  validates_presence_of :title, :content
  
  attr_protected :user_id

  retro_previewable do |r|
    r.channel do |c, options|
      project = options[:project] || Project.current
      c.name = 'blog'
      c.title = _('Blog')
      c.description = _('Blog for %{project}', :project => project.name)
      c.link = c.route(:project_blog_posts_url, project)
    end
    r.item do |i, blog_post, options|
      project = options[:project] || Project.current
      i.title = blog_post.title
      i.description = blog_post.preview
      i.date = blog_post.created_at
      i.link = i.guid = i.route(:project_blog_post_url, project, blog_post)
    end
  end

  cattr_accessor :preview_length
  self.preview_length = 600

  named_scope :categorized_as, lambda {|name|
    return {} if name.blank?    
    matches = find :all, :joins => :categories, :select => 'DISTINCT blog_posts.id', :conditions => ['tags.name = ?', name]
    { :conditions => ['blog_posts.id IN (?)', matches.map(&:id)], :include => :categories }
  }

  named_scope :posted_by, lambda {|user_id|
    return {} if user_id.blank?    
    { :conditions => ['users.id = ?', user_id], :include => :user }
  }

  named_scope :feedable, :order => 'blog_posts.created_at DESC', :limit => 10

  class << self
    
    def searchable_column_names
      [ 'blog_posts.title', 'blog_posts.content' ]
    end
    
    def full_text_search(query)
      find :all,
        :conditions => Retro::Search::exclusive(query, *searchable_column_names),
        :limit => 100,
        :order => 'blog_posts.created_at DESC'      
    end
    
    def per_page
      3
    end
    
  end
    
  def preview    
    return '' if new_record? || content.blank?

    @preview ||= if content.size < preview_length
      content
    else
      short = content.
        gsub(/\r/, '').             # Clean
        first(preview_length - 4).  # Shorten
        gsub(/ ?\w+\Z/m, '')             # Remove all word characters at the end        
      short += ' ...'
      
      paragraphs = short.split("\n\n")
      paragraphs.pop if paragraphs.size > 2

      while paragraphs.size > 1 && paragraphs.last =~ /^(=+.+?=+)|(#+.+?#+)|(h\d\..+?)$/
        paragraphs.pop # strip headlines
      end

      paragraphs.join("\n\n")
    end
  end

  def to_xml_with_comments
    to_xml do |xml|
      xml.comments :type => 'array' do
        comments.each do |comment|          
          comment.to_xml :builder => xml, :skip_instruct => true, :root => 'comment', :type => comment.class.name
        end
      end       
    end
  end

  def serialize_only
    [:id, :title, :content, :created_at]
  end

  def serialize_including
    [:user]
  end

  protected
  
    def before_validation
      # normalize_categories
      self.category_list = category_list.map(&:titleize).join(', ')
    end
  
    def before_validation_on_create
      self.user = User.current unless User.current.public?
      true
    end

    def validate
      if user and user.public?
        errors.add :user_id, 'cannot be public'
      end
      errors.empty?
    end
  
end
