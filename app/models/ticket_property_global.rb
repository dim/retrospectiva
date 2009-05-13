#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
module TicketPropertyGlobal

  def self.included(base)
    base.extend(ClassMethods)    
    base.class_eval do 
      has_many :tickets

      validates_presence_of :name
      validates_uniqueness_of :name, :case_sensitive => false   
      
      include InstanceMethods
    end    
  end
    
  module ClassMethods
    def default
      find_by_default_value(true) || find(:first)
    end  
    
    def global?
      true
    end
  end

  module InstanceMethods    
    def serialize_only
      [:id, :name]
    end

    protected
            
      # Refuse to manually unset the default_value
      def before_validation_on_update
        if not default_value? and default_value_was
          errors.add :default_value, :cannot_be_disabled
        end
        errors.empty?
      end      
  
      def before_destroy
        return false if default_value?
        
        if tickets.any?
          default_value = self.class.default
          attribute_name = self.class.name.downcase + '_id'
          tickets.each do |ticket|         
            ticket.update_attribute(attribute_name, default_value.id)
          end if default_value
        end
        true
      end
      
      def before_update
        if default_value?
          self.class.update_all ['default_value = ?', false], ['id <> ?', self.id] 
        end
        true
      end

      def before_create
        if default_value?
          self.class.update_all ['default_value = ?', false]
        end
        true
      end
    
  end
end