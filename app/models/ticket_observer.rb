#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class TicketObserver < ActiveRecord::Observer

  def before_validation(ticket)
    if ticket.assigned_user.present? and ( ticket.assigned_user.public? or not ticket.assigned_user.permitted?(:tickets, :update, :project => ticket.project) )
      ticket.assigned_user = nil
    end

    if ticket.email.blank?
      ticket.email = nil     
    end

    true
  end

  def before_validation_on_create(ticket)
    unless User.current.public?
      ticket.user = User.current
    end    

    if ticket.user.present?
      ticket.author = ticket.user.name
      ticket.email = ticket.user.email
    end

    true
  end

  def before_update(ticket)
    ticket.properties = ticket.project.ticket_properties.find_all_by_id(ticket.property_ids).index_by(&:ticket_property_type_id).values    
    true
  end

end
