module NavigationHelper

  def main_navigation
    nil
  end

  def base_navigation
    links = []
    if User.current.projects.active.size > 1 || true
      klass = controller.is_a?(ProjectsController) ? 'active' : nil
      links << link_to(_('Projects'), projects_path, :class => klass)
    end
    if User.current.admin?
      klass = controller.is_a?(AdminAreaController) ? 'active' : nil
      links << link_to(_('Admin'), admin_path, :class => klass)      
    end
    links.map {|i| "<li>#{i}</li>" }.join('')
  end

  def top_link(options = {})
    content = link_to(_('Back to top'), '#top')
    if options.delete(:wrap) == false
      content
    else
      content_tag :div, content, options.reverse_merge(:class => 'top-link')      
    end
  end    

  def link_to_if_permitted(name, options = {}, html_options = {}, &block)
    condition = User.current.has_access?(options)
    link_to_if(condition, name, options, html_options, &block) 
  end 

  def link_to_changeset(label, revision, options = {})
    condition = User.current.permitted?(:changesets, :view) &&
      Project.current.existing_revisions.include?(revision)    

    link_to_if condition, label, 
      project_changeset_path(Project.current, revision, params.only(:expand_all)), 
      options.reverse_merge(:title => _('Show changeset %{revision}', :revision => h(revision)))
  end
  
  def link_to_browse(label, path, revision = nil)
    relative_path = relativize_path(path.is_a?(Array) ? path.join('/') : path)
    tokens = relative_path.split('/').reject(&:blank?)
    title = ( tokens.blank? ? 'root' : tokens.join('/') ) + ( revision ? " [#{revision}]" : '' )
    
    link_to_if_permitted label, 
      project_browse_path(Project.current, tokens, :rev => revision),
      :title => _('Browse %{title}', :title => title)      
  end

  def link_to_admin_dashboard(label = nil)
    label ||= _('Dashboard')
    link_to_if User.current.admin?, label, admin_path
  end
  
  def in_place_edit_external_control(label, field_id)
    link_to(label, '#', :id => "#{field_id}-in-place-editor-external-control")
  end

  def link_to_in_place_edit(label, field_id, options = {})
    in_place_edit_external_control(label, field_id) + retro_in_place_editor(field_id, options)
  end
  
  def links_to_account_management
    cf = RetroCM[:general][:user_management]    
    html = []
    if User.current.public?
      html << link_to(_('Login'), login_path)
      html << link_to(_('Register'), new_account_path) if cf[:account_management] && cf[:self_registration]
    else
      html << _('Logged in as %{name}', :name => h(User.current.name))
      html << link_to(_('My Account'), account_path) if cf[:account_management]
      html << link_to(_('Logout'), logout_path)
    end
    html.join(" #{image_tag('dots.gif', :alt => '|')} ")   
  end
  
  def left_side_footer
    separator = ' ' + image_tag('dots.gif', :alt => '|', :class => 'dots') + "\n"        

    elements = []
    elements += view_extension_parts(:footer, :left, :before)
    
    elements << link_to(image_tag('rss.png') + ' ' + _('Feeds'), rss_path, :class => 'strong')

    elements += view_extension_parts(:footer, :left, :between)

    if Project.current and User.current.permitted?(:content, :search)
      elements <<
        "<form action=\"#{project_search_path(Project.current)}\" method=\"get\" class=\"quiert inline\">" +
        _('Search') + ': ' + text_field_tag('q', params[:q], :id => nil) + hidden_field_tag('all', 1, :id => nil) + 
        '</form>'
    end
    elements += view_extension_parts(:footer, :left, :after)
    
    elements.join(separator)
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
