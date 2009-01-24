#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Priority < ActiveRecord::Base
  include TicketPropertyGlobal 

  def self.label
    _('Priority')
  end
  
end
