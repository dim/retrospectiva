#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Repository::Git::Node < Repository::Abstract::Node
  
  def initialize(repos, path, selected_rev = nil, skip_check = false)
    super(repos, sanitize_path(path), selected_rev || 'HEAD')
    raise_invalid_node_error! unless skip_check || exists?
  end

  def revision
    @revision ||= repos.repo.log(selected_revision, path, :n => 1).map(&:id).first 
  end

  def author
    commit.author.name
  end

  def date
    commit.authored_date    
  end
  
  def log
    commit.message
  end

  def dir?
    node.is_a?(Grit::Tree)
  end

  def sub_nodes
    return [] unless dir?

    @sub_nodes ||= node.contents.map do |content|
      self.class.new(repos, path + '/' + content.name, selected_revision, true)
    end.sort_by {|n| [n.content_code, n.name.downcase] }
  end

  def content
    @content ||= dir? ? nil : node.data
  end

  def mime_type
    dir? ? nil : node.mime_type
  end

  def size
    dir? ? 0 : node.size
  end

  def sub_node_count
    dir? ? node.contents.size : 0
  end

  # Returns true if the selected node revision mathces the latest repository revision
  def latest_revision?
    selected_revision == 'HEAD' || selected_revision == repos.history(path, 'HEAD', 1).first
  end


  protected

    def exists?
      node.present? and revision.present?
    end
    
    def commit
      @commit ||= repos.repo.commit(revision)
    end
    
    def node
      @node ||= fetch_node rescue nil
    end

    def sanitize_path(value)
      value.split('/').reject(&:blank?).join('/')
    end
    
    def root?
      path.blank?    
    end
  
  private
  
    def fetch_node
      if root? 
        repos.repo.tree(selected_revision)
      else 
        repos.repo.tree(selected_revision, [path]).contents.first
      end
    end

end  
