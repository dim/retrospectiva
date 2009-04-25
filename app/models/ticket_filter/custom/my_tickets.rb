class TicketFilter::Custom::MyTickets < TicketFilter::Custom::Abstract

  def items
    @items ||= [ 
      Item.new(1, _('Assigned to me')),
      Item.new(2, _('Reported by me')),
      Item.new(3, _('Watched by me')) 
    ]    
  end

  def options
    { :label => _('My Tickets'), :conditions => conditions_proc }
  end
  
  protected
    
    def conditions_proc
      lambda { |item, conditions|
        unless User.current.public?
          conditions << ['tickets.assigned_user_id = ?', User.current.id]   if item.include?(1)
          conditions << ['tickets.user_id = ?', User.current.id]            if item.include?(2)
          conditions << ['ticket_subscribers.user_id = ?', User.current.id] if item.include?(3)
        end
      }
    end

end
