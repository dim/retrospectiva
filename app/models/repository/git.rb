#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Repository::Git < Repository::Abstract

  class << self
    
    def truncate_revision(revision)
      super.first(6)
    end
    
  end

  def active?
    SCM_GIT_ENABLED and super
  end

  def latest_revision
    @latest_revision ||= (repo.rev_list('HEAD', :n => 1).first || 'HEAD')
  end

  def unified_diff(path, revision_a, revision_b)
    return '' unless active?

    text = repo.git.run '', 'diff', '', {}, [revision_a, revision_b, '--', path]
    list = Grit::Diff.list_from_string(repo, text).first
    return '' unless list.present? and list.diff.to_s.starts_with?('--- ')
    
    "--- Revision #{revision_a}\n+++ Revision #{revision_b}\n" + list.diff.
      gsub(/\A\-{3} .+?\n/, '').
      gsub(/\A\+{3} .+?\n/, '')    
  end

  # Returns the revision history for a path starting with a given revision
  def history(path, revision = nil, limit = 100)
    return [] unless active? 
    
    repo.rev_list(revision || latest_revision, path, :n => limit)
  end

  def sync_changesets
    return unless active?
    
    last_changeset = changesets.find :first, :select => 'revision', :order => 'created_at DESC'
    
    revisions = if last_changeset && ( head = repo.commit('HEAD') ) && ( latest = repo.commit(last_changeset.revision) )
      repo.commits_between(latest, head).map(&:id)
    else
      repo.rev_list('HEAD').reverse
    end
    
    synchronize!(revisions)
  end

  def repo
    @repo ||= Grit::Repo.new(path.chomp('/'))
  end

  protected 

    def new_changeset(revision)
      commit = repo.commit(revision)
            
      node_data = { :added => [], :copied => [], :updated => [], :deleted => [], :moved => [] }

      commit.file_changes.each do |change|
        case change.type
        when 'A'
          node_data[:added] << change.a_path          
        when 'D'
          node_data[:deleted] << change.a_path
        when 'M'
          node_data[:updated] << change.a_path
        when 'C'          
          node_data[:copied] << [change.b_path, change.a_path, commit.parents.first.id]
        when 'R'
          node_data[:moved] << [change.b_path, change.a_path, commit.parents.first.id]
        end
      end
      
      changeset = changesets.build :revision => revision.to_s, 
        :author => commit.committer.name, 
        :log => commit.message, 
        :created_at => commit.committed_date      
      [changeset, node_data]
    end

end
