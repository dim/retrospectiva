#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
module Admin::TicketPropertiesHelper

  def properties_path(*args)
    admin_project_ticket_properties_path(*args)
  end

  def property_path(*args)
    admin_project_ticket_property_path(*args)
  end

  def new_property_path(*args)
    new_admin_project_ticket_property_path(*args)
  end

  def edit_property_path(*args)
    edit_admin_project_ticket_property_path(*args)
  end

  def sort_properties_path(*args)
    sort_admin_project_ticket_properties_path(*args)
  end

  def property_values_path(*args)
    admin_project_ticket_property_values_path(*args)
  end

  def property_value_path(*args)
    admin_project_ticket_property_value_path(*args)
  end
  
  def edit_property_value_path(*args)
    edit_admin_project_ticket_property_value_path(*args)
  end  
  
  def new_property_value_path(*args)
    new_admin_project_ticket_property_value_path(*args)
  end  
  
  def sort_property_values_path(*args)
    sort_admin_project_ticket_property_values_path(*args)
  end  
end
