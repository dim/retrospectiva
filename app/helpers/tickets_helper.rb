module TicketsHelper
  include TicketFilterHelper

  def html_classes_for_ticket(ticket)
    html_class_for_ticket_state(ticket) + ' ' + html_class_for_ticket_statement(ticket)
  end

  def last_change_content_one_line(ticket)
    if ticket.changes.last.nil? or ticket.changes.last.content.blank?
      h(datetime_format(ticket.updated_at))
    else
      content = "#{ticket.changes.last.author} (#{datetime_format(ticket.updated_at)})"
      content += ": " + truncate(ticket.changes.last.content.squish, :length => 600)
      h(content)
    end
  end

  def tickets_path(options = {})
    method = [options.delete(:prefix), 'project_tickets_path'].compact.join('_')
    send method, Project.current,
      params.only(:report, :by).merge(@filters.to_params).merge(options)
  end

  def ticket_update(update, tag = nil)
    if !update[:old].blank? && !update[:new].blank?
      RetroI18n._('changed from %{old_value} to %{new_value}', :old_value => wrap_update(update[:old], tag), :new_value => wrap_update(update[:new], tag))
    elsif update[:old].blank?
      RetroI18n._('set to %{value}', :value => wrap_update(update[:new], tag))
    elsif update[:new].blank?
      RetroI18n._('reset (from %{value})', :value => wrap_update(update[:old], tag))
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

  def render_grouped(tickets, group_by = nil)
    return render(tickets) unless GROUP_BY_PROCS[group_by]

    tickets.group_by(&GROUP_BY_PROCS[group_by]).map do |value, ticket_group|
      spacer = content_tag :td, ticket_spacer_value(value, group_by),
        :class => "group quiet centered",
        :colspan => ( property_types.any? ? 8 : 7 )
      "<tr class=\"#{current_cycle}\">#{spacer}</tr>" + render(ticket_group)
    end.join("\n")
  end

  def ticket_group_by(label, value, *aliases)
    aliases.unshift(value)
    link_to_unless aliases.include?(params[:by]), label, tickets_path(:by => value)
  end

  protected

    GROUP_BY_PROCS = {
      'day'       => lambda { |t| t.updated_at.to_date },
      'week'      => lambda { |t| t.updated_at.end_of_week.to_date },
      'month'     => lambda { |t| t.updated_at.end_of_month.to_date },
      'user'      => lambda { |t| t.assigned_user },
      'priority'  => lambda { |t| t.priority },
      'milestone' => lambda { |t| t.milestone }
    }

    def ticket_spacer_value(value, group_by)
      case group_by
      when 'month'
        h I18n.l(value, :format => '%B %Y')
      when 'day', 'week', 'month'
        h(date_format(value))
      when 'user', 'priority', 'milestone'
        value ? h(value.name) : '&mdash'
      else
        '&mdash'
      end
    end

    def html_class_for_ticket_state(ticket)
      "ticket-state-#{ticket.status.state.type}".dasherize
    end

    def html_class_for_ticket_statement(ticket)
      "ticket-statement-#{ticket.status.statement.type}".dasherize
    end

    def wrap_update(value, tag = nil)
      tag ? content_tag(tag, h(value)) : h(value)
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


end
