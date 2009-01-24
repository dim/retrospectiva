module Retrospectiva
  module AccessManager

    class MenuMap < Hash
      def names
        values.map(&:name)        
      end
      
      def push(controller, name, options = {}, &block)
        self[name] = Item.new(controller, name, options, &block)
      end

      class Item
        attr_reader :name, :controller_name
        attr_accessor :rank, :label, :requires, :only, :except
        attr_writer :path

        def initialize(controller_klass, name, options = {}, &block)
          options.symbolize_keys!

          @controller_name = controller_klass.name
          @name     = name.to_s
          @label    = options[:label] || @name.titleize
          @rank     = options[:rank].to_i
          @only     = [options[:only]].flatten.compact.map(&:to_s)
          @except   = [options[:except]].flatten.compact.map(&:to_s)
          @requires = options[:requires]          
          @path     = if options.key?(:path)
            options.delete(:path)
          else
            resource_name = controller_name.gsub(/Controller$/, '').tableize
            lambda { |project| send("project_#{resource_name}_path".to_sym, project) }
          end
          yield self if block_given?
        end
        
        def accessible?(project)
          !requires.is_a?(Proc) || requires.call(project)
        end
        
        def path(object, project)
          object.instance_exec(project, &@path)          
        end
        
        def active?(controller_name, action_name = 'index')
          controller_name == self.controller_name && included_action?(action_name)          
        end
        
        def included_action?(action_name)         
          if only.any?
            only.include?(action_name)
          elsif except.any?
            !except.include?(action_name)
          else
            true
          end
        end
      end      
    end
    
  end
end
