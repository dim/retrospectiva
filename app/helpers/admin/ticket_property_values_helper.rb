#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
module Admin::TicketPropertyValuesHelper
  include Admin::TicketPropertiesHelper

  def links_to_edit_and_destroy(value, type_name)
    link_to_edit(value) + ' ' + 
      ( value.default_value? ? inactive_link(_('Delete')) : link_to_destroy(value, type_name) )
  end
  
  protected

    def link_to_edit(value)
      link_to _('Edit'), edit_property_value_path(@project, @property_type, value)
    end
  
    def link_to_destroy(value, type_name)
      confirmation = _('Really delete this {{record}}?', :record => type_name)
  
      ticket_count = value.tickets.count
      unless ticket_count.zero?
        confirmation << "\n" <<
          _("WARNING: There are currently {{count}} tickets assigned with this property.", :count => ticket_count) << "\n" <<
          _("They will be set back to the default value.")
      end
      
      link_to _('Delete'), property_value_path(@project, @property_type, value),
        :confirm => confirmation, :method => :delete
    end
    

end
