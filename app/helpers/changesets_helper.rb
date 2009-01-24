module ChangesetsHelper
  include DiffHelper
  include RepositoriesHelper

  def changeset_navigation(changeset)
    links = []
    links << link_to(_('Changeset index'), project_changesets_path(Project.current))
    if @previous_changeset
      links << link_to_changeset(_('Previous changeset'), @previous_changeset.revision) 
    end
    if @next_changeset
      links << link_to_changeset(_('Next changeset'), @next_changeset.revision) 
    end
    links.join(' | ')
  end

  def format_changes(changeset)
    html = []

    changeset.changes.each do |change|
      parts = []
      parts << image_tag("ch_#{change.name}.png", :alt => change_label(change), :title => change_label(change))
      parts << if change.name == 'D'
        relativize_path(change.path)
      else
        link_to_show_file(change)
      end
  
      small = if User.current.permitted?(:code, :browse) && change.diffable? && !change.unified_diff.blank?
        link_to _('Quick Diff'), project_changeset_path(Project.current, changeset, :anchor => "ch#{change.id}")
      elsif change.name == 'CP'
        RetroI18n._('copied from {{path}}', :path => link_to_show_file(change, true))
      elsif change.name == 'MV'
        RetroI18n._('moved from {{path}}', :path => link_to_show_file(change, true))
      else
        nil
      end

      parts << "<span class=\"small\">(#{small})</span>" if small
      html << "<li id=\"ch_info_#{change.id}\">#{parts.join(' ')}</li>"
    end
    
    html.join("\n      ")
  end

  def link_to_diff_download(change)
    path = project_diff_path Project.current, relativize_path(change.path).split('/'),
      :rev => change.revision,
      :compare_with => change.previous_revision,
      :format => 'plain'
    link_to_if_permitted _('Download Diff'), path      
  end

  private
  
    def change_label(change)
      { 'M' => _('Updated'), 'A' => _('Added'), 'D' => _('Deleted'), 'CP'=> _('Copied'), 'MV'=> _('Moved') }[change.name]
    end
  
    def link_to_show_file(change, use_from = nil)
      path, revision = if use_from
        [relativize_path(change.from_path), change.from_revision]
      else
        [relativize_path(change.path), change.revision]
      end
      label = path + (use_from ? " [#{truncate(revision, :length => 9)}]" : '')
      link_to_browse label, path, revision
    end

end
