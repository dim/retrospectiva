module NotificationsHelper
  include TicketsHelper

  mattr_accessor :default_format_options
  self.default_format_options = { :columns => 70, :body_indent => 2, :first_indent => 2 }  
    
  def format_content(object, options = {})
    return '' if object.content.blank?

    options = options.symbolize_keys.reverse_merge(default_format_options)
    "\n" + object.content.strip.split(/\n\r?\n/).map do |paragraph| 
      Text::Format.new(options.merge(:text => paragraph)).format
    end.join("\n")
  end
  
  def format_updates(change)
    return '' unless change.updates.any?
    
    "\n" + change.updates.map do |attribute, update|
      "   * #{attribute.humanize}: " + ticket_update(update)
    end.join("\n") + "\n"
  end
    
end