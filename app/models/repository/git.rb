#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Repository::Git < Repository::Abstract

  class << self
    
    def truncate_revision(revision)
      super.first(7)
    end

    def enabled?
      SCM_GIT_ENABLED
    end
    
  end

  def latest_revision
    repo.rev_parse('HEAD')
  end
  memoize :latest_revision

  def unified_diff(path, revision_a, revision_b)
    return '' unless active?
    
    text = repo.command :diff, revision_a, revision_b, '--', path
    text =~ /^Binary files / ? '' : "#--- #{revision_a}\n#+++ #{revision_b}\n#{text}"
  rescue TinyGit::GitExecuteError
    ''
  end

  # Returns the revision history for a path starting with a given revision
  def history(path, revision = nil, limit = 100)
    return [] unless active? 
    
    repo.rev_list(revision || latest_revision, '--', path, :max_count => limit)
  end

  def sync_changesets
    return unless active?
    
    last_changeset = changesets.find :first, :select => 'revision', :order => 'created_at DESC'
    
    revisions = if last_changeset
      repo.rev_list("#{last_changeset.revision}..HEAD", :reverse => true)
    else
      repo.rev_list('HEAD', :reverse => true)
    end
    
    synchronize!(revisions)
  end

  def repo
    TinyGit::Repo::new(path, logger)
  end
  memoize :repo

  protected 

    def new_changeset(revision)
      commit = TinyGit::Object::Commit.new(repo, revision, :find_copies_harder => true)
            
      node_data = { :added => [], :copied => [], :updated => [], :deleted => [], :moved => [] }

      commit.changes.each do |change|
        case change.type
        when 'A'
          node_data[:added] << change.a_path          
        when 'D'
          node_data[:deleted] << change.a_path
        when 'M'
          node_data[:updated] << change.a_path
        when 'C'          
          node_data[:copied] << [change.b_path, change.a_path, commit.parent.sha]
        when 'R'
          node_data[:moved] << [change.b_path, change.a_path, commit.parent.sha]
        end
      end
      
      changeset = changesets.build :revision => revision.to_s, 
        :author => commit.committer.name, 
        :log => commit.message, 
        :created_at => commit.committer.date      
      [changeset, node_data]
    end

end
