#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Repository::Abstract::Node
  extend ActiveSupport::Memoizable

  class NodeError < StandardError
  end
  class InvalidPath < NodeError
  end
  class InvalidPathForRevision < NodeError
  end

  DEFAULT_MIME_TYPE = MIME::Types['application/octet-stream'].first.freeze

  attr_reader :selected_revision, :path

  def initialize(repos, path, selected_revision = nil)   
    @repos = repos
    @path  = path
    @selected_revision = selected_revision.to_s
  end

  # Returns the cache key, which is used to generate the ETag
  def cache_key
    "#{User.current.id}:#{repos.id}:#{path}:#{revision}"
  end

  # Returns the last actual revision for the current node
  # (the one where the node was modified for tha last time)
  def revision
    raise NotImplementedError, 'revision is an abstract method'
  end
  
  # Returns a short representation of the revision
  def short_revision
    repos ? repos.class.truncate_revision(revision) : revision 
  end

  # Returns the author for the selected revision
  def author
    raise NotImplementedError, 'author is an abstract method'
  end

  # Returns the date for the selected revision
  def date
    raise NotImplementedError, 'date is an abstract method'
  end

  # Returns the commit log for the selected revision
  def log
    raise NotImplementedError, 'log is an abstract method'
  end

  # Returns true if the node is a directory, else false
  def dir?
    raise NotImplementedError, 'dir? is an abstract method'
  end

  # Returns an array of sub-nodes
  def sub_nodes
    raise NotImplementedError, 'sub_nodes is an abstract method'
  end

  # Returns the node content
  def content
    exists? && !dir? ? '' : nil
  end

  # Returns the node's mime-type
  def mime_type
    exists? && !dir? ? DEFAULT_MIME_TYPE : nil
  end

  # Returns the node's peroperty hash, Example:
  # { 'attribute 1' => 'value 1', 'attribute 1' => 'value 1' }
  def properties
    {}
  end

  # Returns the actual node name (without the path)
  def name
    File.basename(path).chomp('/') + (dir? ? '/' : '')
  end       
    
  # Returns the node size (0 for directories)
  def size
    dir? ? 0 : content.length
  end
         
  # Returns the sub-node count
  def sub_node_count
    sub_nodes.size
  end
 
  # Returns the content type for the selected node (:dir, :text, :image, :unknown)
  def content_type
    if dir?
      :dir
    elsif mime_type && mime_type.simplified =~ /^image\/(png|jpeg|gif)$/i
      :image
    elsif mime_type && mime_type.encoding != "base64"
      :text
    elsif binary?
      :binary
    else
      :unknown
    end
  end

  # Returns 'inline' if node is textual, else 'attachment'
  def disposition
    [:text, :image].include?(content_type) ? 'inline' : 'attachment'
  end

  # Returns true if the selected node revision mathces the latest repository revision
  def latest_revision?
    selected_revision == repos.latest_revision    
  end

  # Guesses if the file is binary.
  # Logic taken from http://blog.zenspider.com/archives/2006/08/i_miss_perls_b.html
  def binary?
    return true if size.zero?
    unless @binary
      s = content.split(//)
      @binary = ((s.size - s.grep(' '..'~').size) / s.size.to_f) > 0.3
    end
    @binary
  end        

  def content_code
    dir? ? 0 : 1
  end
          
  protected

    attr_reader :repos

    # Returns true if the node exists and is valid, else false
    def exists?
      raise NotImplementedError, 'exists? is an abstract method'
    end            
    
    def raise_invalid_node_error!
      latest = nil
      if selected_revision < repos.latest_revision
        latest = self.class.new(repos, path) rescue nil
      end
      raise latest ? InvalidPathForRevision : InvalidPath      
    end
    
    def convert_to_utf8(content, content_charset)
      return content if content_charset == 'utf-8'
      Iconv.conv('utf-8', content_charset, content) rescue content
    end

end
