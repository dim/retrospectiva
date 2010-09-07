module FormatHelper
  include NavigationHelper

  def datetime_format(datetime)
    return '' unless datetime
    I18n.l datetime.to_time, :format => RetroCM[:content][:format][:datetime]
  end

  def date_format(datetime)
    return '' unless datetime
    I18n.l datetime.to_date, :format => RetroCM[:content][:format][:date]
  end

  def time_format(datetime)
    return '' unless datetime
    I18n.l datetime, :format => RetroCM[:content][:format][:time]
  end

  def boolean_format(value, t_yes = nil, t_no = nil)
    title = value ? (t_yes || _('Yes')) : (t_no || _('No'))
    image_tag value.to_s + '.png', :title => title, :alt => title
  end

  def maximum_attachment_size
    number_to_human_size(RetroCM[:general][:attachments][:max_size].kilobytes)
  end

  def time_interval_in_words(to_time = 0, from_time = Time.zone.now, include_seconds = false)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    interval = distance_of_time_in_words(from_time, to_time, include_seconds)        
    from_time < to_time ? _('in %{period}', :period => interval) : _('%{period} ago', :period => interval)
  end

  def markup(text, options = {})
    options.symbolize_keys!
    wikified = auto_link(post_markup(WikiEngine.markup(text, options[:engine])))    
    format_internal_links(wikified, options)
  end

  def simple_markup(text, options = {})
    wikified = auto_link(simple_format(escape_once(text)))
    format_internal_links(wikified, options)
  end

  def markup_area(name, method, options = {}, html_options = {})
    markup_preview("#{name}_#{method}") + markup_editor(name, method, options, html_options) 
  end

  protected 

    def post_markup(content)
      sanitize(content) 
    end

    def markup_editor(name, method, options = {}, html_options = {})
      html_options.reverse_merge!(
        :onkeydown => 'return catchTab(this,event);', 
        :rows => 10, :cols => 40)
  
      content_tag :div, 
        text_area(name, method, html_options) + links_for_markup_editor("#{name}_#{method}"), 
        :id => "#{name}_#{method}_editor",
        :class => 'markup-editor'
    end

    def links_for_markup_editor(element_id)
      markup_link = link_to _('Markup reference'), markup_reference_path,
        :popup => [_('Reference'), 'height=400,width=800,location=0,status=0,menubar=0,resizable=1,scrollbars=1']    
      preview_link = link_to_remote _('Preview'), 
        :url => markup_preview_path,
        :with => "'content=' + encodeURIComponent($F('#{element_id}')) + '&element_id=#{element_id}_preview'",
        :complete => "Element.hide('#{element_id}_editor'); Element.show('#{element_id}_preview_container'); "
  
      content_tag :div, markup_link + ' | ' + preview_link, :class => 'markup-links'
    end

    def markup_preview(element_id)
      preview_tag = content_tag :div, '', 
        :id => "#{element_id}_preview", 
        :class => 'markup markup-preview'    
          
      content_tag :div, preview_tag + link_for_markup_preview(element_id),
        :style => 'display: none;', 
        :id => "#{element_id}_preview_container"
    end

    def link_for_markup_preview(element_id)
      js_call = "Element.hide('#{element_id}_preview_container'); Element.show('#{element_id}_editor');"
      content_tag :div, link_to_function(_('Close preview'), js_call), 
        :class => 'markup-links'
    end
    
    def format_internal_links(markup, options = {})      
      return markup if Project.current.blank? and not options[:demo] 
      
      WikiEngine.with_text_parts_only(markup) do |text|
        text.gsub(internal_link_pattern) do |match|
          format_internal_link($~, options)
        end      
      end
    end

    def internal_link_pattern
      /\[?(\\?)([#|r]?)(\w+)\]/
    end

    def format_internal_link(match_data, options)
      escape, type, ref = match_data[1, 3]
      
      case escape.blank? and type
      when 'r', ''
        format_internal_changeset_link(ref, options)
      when '#'
        format_internal_ticket_link(ref.to_i, options) 
      else
        "[#{type}#{ref}]"
      end
    end
    
    def format_internal_changeset_link(revision, options = {})
      label = h("[#{revision}]")
      if options[:demo]
        link_to_function(label) 
      else
        link_to_changeset(label, revision)
      end
    end
  
    def format_internal_ticket_link(ticket_id, options = {})
      label = h("[##{ticket_id}]")      
      return link_to_function(label) if options[:demo]

      project = User.current.permitted?(:tickets, :view) ? find_project_for_ticket(ticket_id) : nil
      return label unless project
  
      info = project.existing_tickets[ticket_id]
      link_class = case info[:state]
        when 2 then 'ticket-in-progress'
        when 3 then 'ticket-resolved'
        else        'ticket-open'
        end                                        
      link_to label, project_ticket_path(project, ticket_id),
        :class => link_class, 
        :title => h(info[:summary])
    end

  private 

    def find_project_for_ticket(ticket_id)
      projects = RetroCM[:content][:markup][:global_ticket_refs] ? User.current.projects.active : [Project.current]
      projects.detect do |project|
        !project.existing_tickets[ticket_id].blank?
      end
    end

end
