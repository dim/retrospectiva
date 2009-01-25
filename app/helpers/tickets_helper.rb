module TicketsHelper
  include TicketFilterHelper
  
  def html_classes_for_ticket(ticket)
    html_class_for_ticket_state(ticket) + ' ' + html_class_for_ticket_statement(ticket)
  end

  def last_change_content_one_line(ticket)
    if ticket.changes.last.nil? or ticket.changes.last.content.blank?
      ''
    else
      content = "#{ticket.changes.last.author} (#{datetime_format(ticket.updated_at)})"
      content += ": " + truncate(ticket.changes.last.content.squish, :length => 600)
      h(content)
    end
  end
  
  def hash_for_search_tickets_path
    hash_for_formatted_search_project_tickets_path @filters.to_params.
      merge(params[:report] ? {:report => params[:report]} : {}).
      merge(:project_id => Project.current.to_param, :format => :js)
  end

  def ticket_update(update, tag = nil)
    if !update[:old].blank? && !update[:new].blank?
      RetroI18n._('changed from {{old_value}} to {{new_value}}', :old_value => wrap_update(update[:old], tag), :new_value => wrap_update(update[:new], tag))
    elsif update[:old].blank?
      RetroI18n._('set to {{value}}', :value => wrap_update(update[:new], tag))
    elsif update[:new].blank?
      RetroI18n._('reset (from {{value}})', :value => wrap_update(update[:old], tag))
    end  
  end
    
  def link_to_attachment_download(attachment)
    link_to h(attachment.file_name), 
      project_ticket_download_path(Project.current, @ticket, attachment, attachment.file_name),
      :title => "#{attachment.content_type} &ndash; #{number_to_human_size(attachment.size)}"
  end

  def property_types
    Project.current.ticket_property_types
  end

  def property_select(form_builder, ticket, property_type)
    choices = "<option></option>" +
      options_from_collection_for_select(property_type.ticket_properties, :id, :name, ticket.property_ids)
    select_tag "#{form_builder.object_name}[property_ids][]", choices, :id => "ticket_property_#{property_type.id}_ids"
  end
  
  def custom_properties(ticket)
    property_types.map do |type|
      next nil if ticket.property_map[type].blank?

      title = "#{h(type.name)}: #{h(ticket.property_map[type].name)}"
      content = "#{h(truncate(type.name, :length => 10))}: <em>#{h(truncate(ticket.property_map[type].name, :length => 14))}</em>" 

      "<span class=\"ticket-property\" title=\"#{title}\">#{content}</span>"      
    end.compact.join('<br/>')
  end

  def property_name_value_map(ticket)
    collection = [
      [_('Status'), ticket.status.name],
      [_('Priority'), ticket.priority.name]
    ]
    collection << [_('Milestone'), ticket.milestone.name] if ticket.milestone
    property_types.each do |type|      
      value = @ticket.property_map[type]
      collection << [type.name, value.name] if value
    end
    collection
  end

  def user_select(f)
    if RetroCM[:ticketing][:user_assignment][:field_type] == 'text-field'
      user_select_with_auto_complete(f)
    else
      f.collection_select :assigned_user_id, 
        Project.current.users.with_permission(:tickets, :update), :id, :name, :include_blank => true
    end
  end

  def user_select_with_auto_complete(f)
    selected = f.object.assigned_user
    path = users_project_tickets_path(Project.current, :authenticity_token => form_authenticity_token)
    code = %Q(
      new Ajax.Autocompleter('assigned_user', 'user_selection', '#{path}', { 
        afterUpdateElement: function(text, li) { $('#{f.object_name}_assigned_user_id').value = li.id; }
      });
    ).squish
    content_tag :div,
      text_field_tag(:assigned_user, selected ? h(selected.name) : nil) + 
      f.hidden_field(:assigned_user_id, :wrap => false) + 
      '<div id="user_selection"></div>' + javascript_tag(code)
  end

  def subscription_icon(ticket)
    if ticket.subscribers.include?(User.current)
      image_tag 'watching.png', :alt => _('You are watching this ticket'), :title => _('You are watching this ticket')
    else
      nil
    end
  end
  
  def toggle_internal_navigation(open, close)
    %Q(
      if ($('ticket_#{close}_selector')) Element.hide('ticket_#{close}_selector');
      Element.toggle('ticket_#{open}_selector');
    ).squish
  end
  
  protected
  
    def html_class_for_ticket_state(ticket)
      "ticket-state-#{ticket.status.state.type}".gsub('_', '-')
    end
  
    def html_class_for_ticket_statement(ticket)
      "ticket-statement-#{ticket.status.statement.type}".gsub('_', '-')
    end
    
    def wrap_update(value, tag = nil)
      tag ? content_tag(tag, h(value)) : h(value)
    end

end
