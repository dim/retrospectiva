module Retrospectiva
  module AccessManager

    class PermissionMap < Hash
      def resource(name, options = {}, &block)
        self[name.to_s] = PermissionResource.new(name, options, &block)
      end
      
      def find(resource, action)
        self[resource.to_s][action.to_s] rescue nil
      end
    end

    class PermissionResource < Hash
      attr_reader :name, :label
      
      def initialize(name, options = {}, &block)
        super()
        @name = name.to_s
        @label = options[:label] || @name.to_s.humanize
        yield self if block_given?
      end
      
      def <=>(other)
        _(label) <=> _(other.label)
      end
      
      def permission(name, options = {}, &block)
        self[name.to_s] = Permission.new(name, options, &block)
      end
      
      protected
      
        def default(*args)
          nil
        end
    end

    class Permission
      attr_reader :name, :label, :callback

      def initialize(name, options = {}, &callback)
        @name, @callback = name.to_s, callback
        @label = options[:label] || @name.to_s.humanize        
      end
      
      def evaluate(*args)
        callback.call(*args) rescue nil
      end
      
      def <=>(other)
        _(label) <=> _(other.label)
      end
      
      def custom?
        callback.is_a?(Proc)
      end      

    end
    
  end
end
