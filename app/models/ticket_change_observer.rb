#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class TicketChangeObserver < ActiveRecord::Observer

  def before_validation(change)
    if change.email.blank?
      change.email = nil     
    end
    true
  end
  
  def before_validation_on_create(change)
    unless User.current.public?
      change.user = User.current
    end

    if change.user.present?
      change.author = change.user.name
      change.email = change.user.email
    end

    change.updates = change.updates_index    
    true
  end

  def before_create(change)
    change.ticket.save
  end

  def after_create(change)
    change.ticket.permitted_subscribers.each do |user|
      Notifications.queue_ticket_update_note(change, :recipients => user.email)                 
    end    
  end


end
