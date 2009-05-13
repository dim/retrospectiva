#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
module TicketFilterHelper

  def ticket_filter_selector(filters)
    filters.map do |filter|
      title = content_tag :dt, h(filter.label) + ':'
      links = content_tag :dd, ticket_filter_links(filters, filter)
      content_tag :dl, title + links
    end.join("\n")
  end

  protected
      
    def ticket_filter_links(filters, filter)
      filter.map do |record|
        exclusive = exclusive_filter_link(filter, record)      
        inclusive = inclusive_filter_link(filters, filter, record)      
        content_tag(:div, exclusive + ' ' + inclusive, :class => 'option')
      end.join("\n")
    end       
  
    def exclusive_filter_link(filter, record)
      options = { filter.name => [record.id] }
      options.update(params.only(:by))
      
      link_to record.name, project_tickets_path(Project.current, options),
        :title => _('Select filter'), 
        :class => (filter.include?(record.id) ? 'active' : nil)  
    end
  
    def inclusive_filter_link(filters, filter, record)
      icon    = filter.include?(record.id) ?
        image_tag('minus.png', :alt => _('Remove filter')) : 
        image_tag('plus.png', :alt => _('Add filter'))      
      title   = filter.include?(record.id) ? _('Remove filter') : _('Add filter')
      options = filter.include?(record.id) ? 
        filters.excluding(filter.name, record.id) :
        filters.including(filter.name, record.id)        
      options.update(params.only(:by))
      
      link_to icon, project_tickets_path(Project.current, options), :title => title
    end     

end
