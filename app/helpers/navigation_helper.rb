module NavigationHelper

  def main_navigation
    nil
  end

  def base_navigation
    links = []
    if User.current.active_projects.size > 1 || true
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
      html << _('Logged in as {{username}}', :username => h(User.current.username))
      html << link_to(_('My Account'), account_path) if cf[:account_management]
      html << link_to(_('Logout'), logout_path)
    end
    html.join(" #{image_tag('dots.gif', :alt => '|')} ")   
  end
  
  def left_side_footer
    separator = ' ' + image_tag('dots.gif', :alt => '|', :class => 'dots') + "\n"        

    elements = []
    elements += view_extension_parts(:footer, :left, :before)
    
    if @rss_channel
      title = _('RSS Feed')
      image = image_tag('rss.png', :alt => @rss_channel.title)
      elements << link_to("#{image} #{title}", @rss_channel.rss_path, 
        :title => @rss_channel.title, 
        :class => 'strong')
    end

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

end
