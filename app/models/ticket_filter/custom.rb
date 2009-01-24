module TicketFilter::Custom

  module UserFilter

    Item = Struct.new(:id, :name)  

    def self.items
      [ Item.new(1, _('Assigned to me')),
        Item.new(2, _('Reported by me')),
        Item.new(3, _('Watched by me')) 
      ]    
    end

    def self.lambda_for_conditions
      lambda { |item, conditions|
        unless User.current.public?
          conditions << ['tickets.assigned_user_id = ?', User.current.id]   if item.include?(1)
          conditions << ['tickets.user_id = ?', User.current.id]            if item.include?(2)
          conditions << ['ticket_subscribers.user_id = ?', User.current.id] if item.include?(3)
        end
      }
    end
    
  end

end
