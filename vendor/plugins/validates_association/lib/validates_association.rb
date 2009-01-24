module ActiveRecord
  module Validations
    module ClassMethods
      
      def validates_association_of(*association_names)
        configuration = { :on => :save }
        configuration.update(association_names.extract_options!)
    
        send(validation_method(configuration[:on]), configuration) do |record|
          [association_names].flatten.each do |association|
            reflection = record.class.reflect_on_association(association.to_sym)
            value = record.respond_to?(association) ? record.send(association) : record[association]
            record.errors.add(reflection.primary_key_name, :blank, :default => configuration[:message]) if value.blank?
          end
        end        
      end
  
    end
  end
end