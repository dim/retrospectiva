#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Changeset < ActiveRecord::Base
  belongs_to :repository
  belongs_to :user
  has_many :changes, :extend => AssociationProxies::ChangesetChanges, :dependent => :destroy
  has_and_belongs_to_many :projects, :uniq => true

  validates_presence_of :repository_id, :revision
  validates_uniqueness_of :revision, :scope => :repository_id

  attr_accessor :skip_project_synchronization
  
  retro_previewable do |r|
    r.channel do |c, options|
      project = options[:project] || Project.current
      c.name = 'changesets'
      c.title = _('Changesets')
      c.description = _('Changesets for {{project}}', :project => project.name)
      c.link = c.route(:project_changesets_url, project)
    end
    r.item do |i, changeset, options|
      project = options[:project] || Project.current
      i.title = _('Changeset {{revision}}', :revision => changeset.revision)
      i.description = changeset.log
      i.author = changeset.author
      i.date = changeset.revised_at
      i.link = i.guid = i.route(:project_changeset_url, project, changeset)
    end
  end
 
  class << self
    def per_page
      5
    end

    def searchable_column_names
      [ 'changesets.revision', 'changesets.log', 'changesets.author' ]
    end
    
    def full_text_search(query)
      filter = Retro::Search::exclusive query, *searchable_column_names
      find :all,
        :conditions => filter,
        :limit => 100,
        :order => 'changesets.revised_at DESC'      
    end

    def update_project_associations!
      pattern = connection.concat('projects.root_path', "'%'")
      sql = %Q{
        INSERT INTO changesets_projects (changeset_id, project_id)
        SELECT DISTINCT changesets.id AS changeset_id, projects.id AS project_id
        FROM changesets
        INNER JOIN projects 
          ON projects.repository_id = changesets.repository_id
         AND projects.closed = ?
        INNER JOIN changes 
          ON changes.changeset_id = changesets.id 
         AND ( projects.root_path IS NULL OR changes.path LIKE #{pattern} OR changes.from_path LIKE #{pattern} )
        LEFT OUTER JOIN changesets_projects
          ON changesets_projects.changeset_id = changesets.id 
         AND changesets_projects.project_id = projects.id 
        WHERE changesets_projects.changeset_id IS NULL
      }.squish
      connection.insert sanitize_sql([sql, false])
    end

    def delete_all(*args)
      expire_cache
      super    
    end
    
    def destroy_all(*args)
      expire_cache
      super
    end
    
    def expire_cache
      ActionController::Base.new.expire_fragment(%r{changesets/changeset/\d+})
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
      :conditions => ['changesets.revised_at > ?', revised_at],
      :order => 'changesets.revised_at'
  end

  def previous_by_project(project)    
    project.changesets.find :first, 
      :conditions => ['changesets.revised_at < ?', revised_at],
      :order => 'changesets.revised_at DESC'
  end

end
