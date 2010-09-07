module ChangesetsHelper
  include DiffHelper
  include RepositoriesHelper

  def changeset_navigation(changeset)
    links = []
    links << link_to(_('Changeset index'), project_changesets_path(Project.current))
    
    if params[:expand_all]
      links << link_to(_('Hide Quick Diffs'), project_changeset_path(Project.current, changeset))
    else
      links << link_to(_('Show Quick Diffs'), project_changeset_path(Project.current, changeset, :expand_all => '1'))
    end if permitted?(:code, :browse)
    
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
      parts << content_tag(:span, link_to_show_file(change), :class => 'strong')
  
      small, quick_diff = nil, nil
      if permitted?(:code, :browse) && change.diffable? && !change.unified_diff.blank?
        small = link_to_quick_diff(changeset, change)
        if params[:expand_all]
          quick_diff = render :partial => 'quick_diff', :locals => { :change => change }
        end
      elsif change.name == 'CP'
        small = RetroI18n._('copied from %{path}', :path => link_to_show_file(change, true))
      elsif change.name == 'MV'
        small = RetroI18n._('moved from %{path}', :path => link_to_show_file(change, true))
      end

      parts << "<span class=\"small\">(#{small})</span>" if small
      parts << quick_diff if quick_diff
      html  << "<li id=\"ch_info_#{change.id}\">#{parts.join(' ')}</li>"
    end
    
    html.join("\n      ")
  end

  def link_to_diff_download(change)
    path = project_diff_path Project.current, relativize_path(change.path).split('/'),
      :rev => change.revision,
      :compare_with => change.previous_revision,
      :format => 'plain'
    link_to_if_permitted _('Download'), path      
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
      change.name == 'D' ? label : link_to_browse(label, path, revision)
    end

    def link_to_quick_diff(changeset, change)
      link_to_remote _('Quick Diff'), 
        :url => diff_project_changeset_path(Project.current, changeset, :change_id => change.id),
        :update => "ch_info_#{change.id}",
        :before => "var cb = $('ch_#{change.id}'); if(cb) { cb.toggle(); return false; };",
        :position => :bottom,
        :method => :get    
    end
  
end
