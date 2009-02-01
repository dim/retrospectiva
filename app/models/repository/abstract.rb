#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Repository::Abstract < ::Repository
  extend ActiveSupport::Memoizable

  class << self

    def subclasses
      subclasses_preloaded?
      super
    end
    
    def truncate_revision(revision)
      revision.to_s
    end
    
    private

      def subclasses_preloaded?
        @subclasses_preloaded ||= ActiveSupport::Dependencies.load_paths.each do |root|
          Dir[File.join(root, 'repository', '*.rb')].each do |file|
            type = File.basename(file, '.rb')
            Repository[type]
          end
        end and true
      end

  end

  # Determines of the repository is ready to be used
  def active?
    node('').present? rescue false
  end
  memoize :active?

  # Returns the latest revision for a repository
  def latest_revision 
    raise NotImplementedError, 'latest_revision is an abstract method'
  end 
  
  # Returns a unified diff between two revisions of a given repository path, Example:
  #   repository.unified_diff('app/controllers/application.rb', 120, 125)
  def unified_diff(path, revision_a, revision_b)
    raise NotImplementedError, 'unified_diff is an abstract method'
  end  

  # Returns the revision history for a path starting with a given revision
  def history(path, revision = nil, limit = nil)
    raise NotImplementedError, 'history is an abstract method'    
  end

  # Syncronizes the database tables as needed with the repository
  def sync_changesets
    raise NotImplementedError, 'sync_changesets is an abstract method'
  end

  # Returns a repository node
  # 
  # Parameters:
  # <tt>path</tt> - Path within the repository
  # <tt>rev</tt> - Node revision; latest revision is selected if this parameter is left blank
  # 
  # Example:
  #   repository.node('app/controllers/application.rb', 150)
  def node(path, rev = nil)
    if self.class::Node == ::Repository::Abstract::Node
      require_or_load "#{self.class.name}::Node".underscore
    end
    self.class::Node.new(self, path, rev)
  end  

  def visible_path?(path)
    hidden_path_patterns.detect do |pattern|
      File.fnmatch?(pattern, path)
    end.nil?
  end
  
  protected

    def hidden_path_patterns
      @hidden_paths_patterns ||= hidden_paths.to_s.split(/\r?\n/).map(&:strip).reject(&:blank?)      
    end

    def log(level, action, message)
      logger.send level, "[#{self.class.name.demodulize}:#{name}:#{action}] #{message}"
    end

    def create_changeset!(revision)
      log :debug, 'SYNC', "Revision: #{revision}"
      next if changesets.exists?(:revision => revision.to_s)
      
      changeset, node_data = new_changeset(revision)
      changeset.changes.build_copied(*node_data[:copied])
      changeset.changes.build_moved(*node_data[:moved])
      changeset.changes.build_added(*node_data[:added])
      changeset.changes.build_deleted(*node_data[:deleted])
      changeset.changes.build_modified(*node_data[:updated])  
      changeset.save!
      
      log :info, 'SYNC', "Added revision #{revision}"
    rescue ActiveRecord::RecordInvalid
      log :error, 'SYNC', "Revision already exists!"
    rescue => other
      log :error, 'SYNC', other.message
    end

end
