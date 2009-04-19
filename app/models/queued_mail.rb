#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class QueuedMail < ActiveRecord::Base
  serialize :object
  validates_presence_of :object, :mailer_class_name
 
  named_scope :pending, :conditions => ['delivered_at IS NULL'], :order => 'created_at'
  
  def mailer_class
    mailer_class_name.constantize rescue nil
  end

  def deliver!
    if mailer_class
      mailer_class.deliver(object) 
      deactivate!
    else
      false      
    end
  end
  
  def deactivate!
    update_attribute :delivered_at, Time.now.utc
  end

end
