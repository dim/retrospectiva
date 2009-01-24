module ProjectAreaHelper
  include NavigationHelper
  
  def link_to_changeset(label, revision)
    link_to_if_permitted label, 
      project_changeset_path(Project.current, revision),
     :title => _('Show changeset {{revision}}', :revision => h(revision))
  end

  def link_to_browse(label, path, revision = nil)
    relative_path = relativize_path(path.is_a?(Array) ? path.join('/') : path)
    tokens = relative_path.split('/').reject(&:blank?)
    title = ( tokens.blank? ? 'root' : tokens.join('/') ) + ( revision ? " [#{revision}]" : '' )    
    
    link_to_if_permitted label, project_browse_path(Project.current, tokens, :rev => revision),
      :title => _('Browse {{title}}', :title => title)      
  end
  
  def main_navigation
    RetroAM.sorted_menu_items(Project.current.enabled_modules).map do |item|
      path = item.path(self, Project.current)
      
      next unless User.current.has_access?(path)
      link_to _(item.label), path, 
        :class => (item.active?(controller.class.name, controller.action_name) ? 'active' : nil)      
    end.compact.map do |link|
      "<li>#{link}</li>"
    end.join('')
  end

  # Override default named route method 
  def project_browse_path(project, path = nil, options = {})
    options.delete(:rev) if options.key?(:rev) and options[:rev].blank?
    super(project, path, options)
  end

  # Override default named route method 
  def project_revisions_path(project, path = nil, options = {})
    options.delete(:rev) if options.key?(:rev) and options[:rev].blank?
    super(project, path, options)
  end

  # Override default named route method 
  def project_download_path(project, path = nil, options = {})
    options.delete(:rev) if options.key?(:rev) and options[:rev].blank?
    super(project, path, options)
  end
  
  # Override default named route method 
  def project_diff_path(project, path = nil, options = {})
    options.delete(:rev) if options.key?(:rev) and options[:rev].blank?
    super(project, path, options)
  end
  
  protected

    def relativize_path(full_path)
      path = Project.current.relativize_path(full_path)
      path.blank? ? '/' : path
    end  

end
