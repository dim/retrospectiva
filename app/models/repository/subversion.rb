#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Repository::Subversion < Repository::Abstract

  def self.enabled?
    SCM_SUBVERSION_ENABLED
  end

  def active?
    self.class.enabled? and ( open_fs.present? rescue false )
  end
  
  def latest_revision
    active? ? fs.youngest_rev.to_s : 0
  end
  memoize :latest_revision

  def unified_diff(path, revision_a, revision_b)
    diff = ''
    begin
      root_a = fs.root(revision_a.to_i)
      root_b = fs.root(revision_b.to_i)
      differ = Svn::Fs::FileDiff.new(root_a, path, root_b, path)

      unless differ.binary?
        header_a = "Revision #{root_a.node_created_rev(path)}"
        header_b = "Revision #{root_b.node_created_rev(path)}"
        diff = differ.unified(header_a, header_b)
        differ = nil
      end
      root_a.close
      root_b.close
    rescue
    end
    diff
  end  

  def history(path, revision = nil, limit = 100)
    fs.history(path, 0, (revision || latest_revision).to_i).map {|r| r.last.to_s }.first(limit)
  rescue Svn::Error::FS_NOT_FOUND, Svn::Error::FS_NO_SUCH_REVISION
    []
  end

  def sync_changesets
    return unless active?

    latest_changeset = changesets.find(:first, :select => 'revision', :order => 'created_at DESC')
    start = latest_changeset ? latest_changeset.revision.to_i + 1: 1
    stop  = latest_revision.to_i
    synchronize!((start..stop).to_a) unless start > stop
  end

  def fs
    self.class.reload_repository_fs_cache unless self.class.repository_fs_cache[id]
    self.class.repository_fs_cache[id] || open_fs
  end

  def open_fs
    Svn::Repos.open(path.chomp('/')).fs
  end

  protected
      
    @@repository_fs_cache = {}
    cattr_reader :repository_fs_cache

    def self.reload_repository_fs_cache
      @@repository_fs_cache = find(:all).inject({}) do |result, record|
        fs = record.open_fs rescue nil
        result[record.id] = fs if fs
        result
      end  
    end

    def after_save
      self.class.reload_repository_fs_cache    
    end

    def new_changeset(revision = nil)
      revision ||= latest_revision
      info = Svn::Info.new(path.chomp('/'), revision.to_i)
      
      node_data = [:added, :updated, :copied, :deleted].inject({}) do |result, type|
        result.merge type => (info.send("#{type}_dirs") + info.send("#{type}_files"))
      end
    
      node_data[:moved] = node_data[:copied].inject([]) do |result, copied_node|
        result << copied_node if node_data[:deleted].delete(copied_node[1])
        result    
      end
      node_data[:copied] -= node_data[:moved]
  
      changeset = changesets.build :revision => revision.to_s, 
        :author => info.author,
        :log => info.log,
        :created_at => info.date
      [changeset, node_data]
    end
  
end
  
