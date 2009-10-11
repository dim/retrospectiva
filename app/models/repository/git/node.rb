#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Repository::Git::Node < Repository::Abstract::Node
 
  def initialize(repos, path, selected_rev = nil, skip_check = false, blob_info = nil)
    super(repos, sanitize_path(path), selected_rev || repos.latest_revision)
    @blob_info = blob_info
    raise_invalid_node_error! unless skip_check || exists?
  end

  def revision
    root? ? repos.latest_revision : repos.repo.rev_list(selected_revision, '--', path, :max_count => 1).first 
  end
  memoize :revision

  def author
    commit.author.name
  end

  def date
    commit.author.date    
  end
  
  def log
    commit.message
  end

  def dir?
    node[:type] == 'tree'
  end

  def sub_nodes
    return [] unless dir?

    node[:contents].map do |hash|
      self.class.new(repos, hash[:path], selected_revision, true, hash[:type] == 'blob' ? hash : nil)
    end.compact.sort_by {|n| [n.content_code, n.name.downcase] }
  end
  memoize :sub_nodes

  def content
    @content = true
    dir? ? nil : blob.contents
  end

  def mime_type
    dir? ? nil : guess_mime_type
  end

  def size
    dir? ? 0 : (@content ? blob.contents.size : blob.size)
  end

  def sub_node_count
    dir? ? node[:contents].size : 0
  end

  # Returns true if the selected node revision mathces the latest repository revision
  def latest_revision?
    selected_revision == 'HEAD' || selected_revision == repos.latest_revision
  end

  protected

    def exists?
      ['blob', 'tree'].include?(node[:type]) and revision.present?
    rescue TinyGit::GitExecuteError
      false
    end
    
    def commit
      @commit ||= repos.repo.commit(revision)
    end

    def blob
      @blob ||= dir? ? nil : repos.repo.blob(node[:sha])
    end
    
    def node
      if root?
        { :sha => selected_revision, :type => 'tree', :contents => sanitize_tree(repos.repo.ls_tree(selected_revision)) }
      elsif @blob_info
        @blob_info
      else
        tree = sanitize_tree(repos.repo.ls_tree(selected_revision, '--', path, File.join(path, '*'), :t => true))
        hash = tree.find {|i| i[:path] == path }
        hash ? tree.delete(hash).merge(:contents => tree) : {}
      end
    end
    memoize :node
        
    def sanitize_path(value)
      value.split('/').reject(&:blank?).join('/')
    end
    
    def sanitize_tree(tree)
      tree.select do |hash| 
        hash.is_a?(Hash) and hash[:path].starts_with?(path) and ['blob', 'tree'].include?(hash[:type])
      end
    end
    
    def root?
      path.blank?    
    end
  
  private

    def guess_mime_type
      guesses = MIME::Types.type_for(name) rescue []
      guesses.any? ? guesses.first : MIME::Types['application/octet-stream'].first
    end

end  
