#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Repository::Subversion::Node < Repository::Abstract::Node  
  
  def initialize(repos, path, selected_revision = nil, skip_content = false)
    selected_revision = Kernel.Float(selected_revision || repos.latest_revision).to_i rescue 0
    if selected_revision < 1 || selected_revision > repos.latest_revision.to_i
      raise Repository::InvalidRevision
    end
      
    super(repos, path, selected_revision)  
    
    begin
      root = repos.fs.root(self.selected_revision.to_i)
    rescue # no such revision     
      raise Repository::RevisionNotFound
    end 
            
    @node_type = root.check_path(self.path)
    raise_invalid_node_error! unless exists?

    @size      = dir? ? 0 : root.file_length(path).to_i
    @revision  = root.node_created_rev(path).to_s
    @proplist  = repos.fs.proplist(revision.to_i)
  
    @properties     = root.node_proplist(path)                          
    @sub_node_names = dir? ? root.dir_entries(path).keys : []
    @mime_type      = verify_mime_type
    
    @content = read_content(root) unless skip_content
    root.close
  end      

  def revision
    @revision
  end

  def author
    @proplist[Svn::Core::PROP_REVISION_AUTHOR] || ''
  end

  def date
    @proplist[Svn::Core::PROP_REVISION_DATE]
  end
  
  def log
    @proplist[Svn::Core::PROP_REVISION_LOG] || ''
  end
    
  def dir?
    @node_type == Svn::Core::NODE_DIR
  end

  def sub_nodes
    @sub_node_names.collect do |name|
      node_path = File.join(path, name)
      repos.visible_path?(node_path) ? self.class.new(repos, node_path, selected_revision, true) : nil
    end.compact.sort_by { |node| [node.content_code, node.name.downcase] }
  end

  def content
    dir? ? nil : @content.to_s
  end

  def mime_type
    dir? ? nil : @mime_type
  end

  def properties
    @properties
  end

  def size
    dir? ? 0 : @size
  end
         
  def sub_node_count
    @sub_node_names.size
  end

  protected

    def exists?
      @node_type != Svn::Core::NODE_NONE && repos.visible_path?(path)
    end

    def verify_mime_type
      return nil if dir?
  
      svn_type = MIME::Types[properties[Svn::Core::PROP_MIME_TYPE]].first      
      if svn_type.blank? || svn_type == DEFAULT_MIME_TYPE
        guesses = MIME::Types.of(name) rescue []
        guesses.first || DEFAULT_MIME_TYPE
      else
        svn_type
      end
    end

    def read_content(root)
      return nil if dir?

      svn_type = properties[Svn::Core::PROP_MIME_TYPE]      
      charset = svn_type.blank? ? nil : svn_type.slice(/charset=([A-Za-z0-9\-_]+)/, 1)
      convert_to_utf8(root.file_contents(path, &:read), charset || 'utf-8')
    end
      
end  
