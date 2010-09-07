#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Changeset < ActiveRecord::Base
  belongs_to :repository
  belongs_to :user
  has_many :changes, :extend => AssociationProxies::ChangesetChanges, :dependent => :destroy
  has_and_belongs_to_many :projects, :uniq => true

  validates_presence_of :repository_id, :revision
  validates_uniqueness_of :revision, :case_sensitive => false, :scope => :repository_id

  after_create :create_changeset_project_relations!
  after_create :update_project_revision_cache!

  attr_accessor :bulk_synchronization
  
  retro_previewable do |r|
    r.channel do |c, options|
      project = options[:project] || Project.current
      c.name = 'changesets'
      c.title = _('Changesets')
      c.description = _('Changesets for %{project}', :project => project.name)
      c.link = c.route(:project_changesets_url, project)
    end
    r.item do |i, changeset, options|
      project = options[:project] || Project.current
      i.title = _('Changeset %{revision}', :revision => changeset.revision)
      i.description = changeset.log
      i.author = changeset.author
      i.date = changeset.created_at
      i.link = i.guid = i.route(:project_changeset_url, project, changeset)
    end
  end
 
  named_scope :feedable, :limit => 10, :order => 'changesets.created_at DESC'    
  
  class << self
    def per_page
      5
    end

    def searchable_column_names
      [ 'changesets.revision', 'changesets.log', 'changesets.author' ]
    end
    
    def full_text_search(query)
      filter = Retro::Search::exclusive query, *searchable_column_names
      feedable.find :all, :conditions => filter, :limit => 100
    end

    def update_project_associations!
      pattern = connection.concat('projects.root_path', "'%'")
      sql = %Q{
        INSERT INTO changesets_projects (changeset_id, project_id)
        SELECT DISTINCT changesets.id AS changeset_id, projects.id AS project_id
        FROM changesets
        INNER JOIN projects 
          ON projects.repository_id = changesets.repository_id
        INNER JOIN changes 
          ON changes.changeset_id = changesets.id 
         AND ( projects.root_path IS NULL OR projects.root_path = '' OR changes.path LIKE #{pattern} OR changes.from_path LIKE #{pattern} )
        LEFT OUTER JOIN changesets_projects
          ON changesets_projects.changeset_id = changesets.id 
         AND changesets_projects.project_id = projects.id 
        WHERE changesets_projects.changeset_id IS NULL
      }.squish
      connection.send :update, sql
    end

    def delete_all(*args)
      expire_cache!
      super    
    end
    
    def destroy_all(*args)
      expire_cache!
      super
    end
    
    def expire_cache!
      ActionController::Base.new.expire_fragment(/changes/)
    end

  end 
  
  def to_param
    revision
  end

  def short_revision
    @short_revision ||= repository ? repository.class.truncate_revision(revision) : revision
  end
  
  def next_by_project(project)
    project.changesets.find :first, 
      :conditions => ['changesets.created_at > ?', created_at],
      :order => 'changesets.created_at'
  end

  def previous_by_project(project)    
    project.changesets.find :first, 
      :conditions => ['changesets.created_at < ?', created_at],
      :order => 'changesets.created_at DESC'
  end

  def serialize_only
    [:id, :author, :revision, :log, :created_at]
  end

  protected

    def create_changeset_project_relations!
      return true if bulk_synchronization
    
      relevant_paths = changes.map do |change|
        [change.path, change.from_path].compact
      end.flatten
  
      self.projects = repository.projects.select do |project|
        project.root_path.blank? || relevant_paths.find {|path| path.starts_with?(project.root_path) }
      end
    end
  
    def update_project_revision_cache!
      return true if bulk_synchronization

      projects.each do |project|
        project.update_attribute :existing_revisions, (project.existing_revisions + [revision]).uniq
      end
    end    

end
