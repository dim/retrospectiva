#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class TicketProperty < ActiveRecord::Base
  has_and_belongs_to_many :tickets, :uniq => true
  belongs_to :ticket_property_type
    
  validates_presence_of :ticket_property_type_id
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :ticket_property_type_id  
  validates_length_of :name, :in => 2..40
  
  def type
    ticket_property_type
  end

  def type_id
    ticket_property_type_id
  end
  
  protected
  
    def before_validation_on_create
      self.rank ||= 9999
      true
    end

end
