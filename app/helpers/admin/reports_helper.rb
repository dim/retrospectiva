module Admin::ReportsHelper

  def report_filter_selector(f)
    TicketFilter::Collection.new(@ticket_report.filter_options, @project).map do |filter|
      title = content_tag(:dt, h(filter.label))
      links = content_tag(:dd, filter_selection(f, filter))
      content_tag(:dl, title + links)
    end.join("\n")
  end

  protected

    def filter_selection(f, filter)
      filter.map do |record|
        element_id = "ticket_report_filter_options_#{filter.name}_#{record.id}"
        checked = filter.include?(record.id)
        
        check_box_tag("ticket_report[filter_options][#{filter.name}][]", record.id, checked, :id => element_id) + 
          f.click_choice(_(record.name), :for => element_id)
      end.join('&nbsp; ')
    end

end
