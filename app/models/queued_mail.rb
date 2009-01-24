#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class QueuedMail < ActiveRecord::Base
  serialize :object
  validates_presence_of :object, :mailer_class_name
 
  named_scope :pending, :conditions => ['delivered_at IS NULL'], :order => 'created_at'
  
  def mailer_class
    @mailer_class ||= mailer_class_name.constantize rescue nil
  end

  def deliver!
    mailer_class ? mailer_class.deliver(object) && deactivate! : false 
  end
  
  def deactivate!
    t = self.class.default_timezone == :utc ? Time.now.utc : Time.now
    update_attribute :delivered_at, t
  end

end
