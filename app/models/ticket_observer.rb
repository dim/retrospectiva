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

  def after_save(ticket)
    existing_tickets = ticket.project.existing_tickets
    unless existing_tickets[ticket.id].is_a?(Hash) &&  
      existing_tickets[ticket.id][:state] == ticket.status.state_id && 
      existing_tickets[ticket.id][:summary] == ticket.summary

      existing_tickets.merge!(ticket.id => { :state => ticket.status.state_id, :summary => ticket.summary })
      ticket.project.update_attribute(:existing_tickets, existing_tickets)
    end
    
    if RetroCM[:ticketing][:subscription][:subscribe_on_assignment] and 
        ticket.assigned_user and ticket.assigned_user.permitted?(:tickets, :watch, :project => ticket.project)
      
      ticket.subscribers << ticket.assigned_user
    end
    
    true
  end

  def after_destroy(ticket)
    existing_tickets = ticket.project.existing_tickets
    if existing_tickets.key?(ticket.id)  
      existing_tickets.delete(ticket.id)
      ticket.project.update_attribute(:existing_tickets, existing_tickets)
    end
  end

end
