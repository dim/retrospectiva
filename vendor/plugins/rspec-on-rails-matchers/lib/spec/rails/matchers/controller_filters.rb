module Spec
  module Rails
    module Matchers
      class ControllerFilter
        def initialize(type, method, options = {})
          @type, @method = type.to_sym, method.to_sym
          @options = [:only, :except].inject({}) do |result, key|
            result[key] = Set.new [options[key]].flatten.map(&:to_s).reverse if options[key]
            result
          end.merge(options.except(:only, :except))
        end
        
        def matches?(actual)
          @klass = actual.is_a?(ActionController::Base) ? actual.class : actual
          @klass.filter_chain.select do |filter|
            filter.type == @type and filter.method == @method and filter.options == @options
          end.any?
        end
        
        def failure_message
          return "expected #{@klass.name} to #{description}"
        end
        
        def negative_failure_message
          return "expected #{@klass.name} not to #{description}"
        end
        
        def description
          msg = ['a', 'e', 'i', 'o', 'u', 'h'].include?(@type.to_s.first) ? "an #{@type}" : "a #{@type}" 
          "have #{msg} filter for #{@method.inspect}"
        end  
      end
      
      def have_filter(type, method, options={})
        Matchers::ControllerFilter.new(type, method, options)
      end
    end
  end
end
