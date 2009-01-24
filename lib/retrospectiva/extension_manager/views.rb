module Retrospectiva
  module ExtensionManager
    module Views
      extend self

      def register_extension(path, *keys)      
        current_node = node(*keys) 
        current_node << path unless current_node.partials.include?(path)
      end

      def extensions(*keys)
        paths = []        
        each_node(*keys) do |node|
          paths << node.partials
        end
        paths.flatten.uniq
      end
    
      private 

        def root_node
          @root_node ||= ViewExtension.new
        end    
    
        def node(*keys)
          each_node(*keys)
        end  

        def each_node(*keys)
          node = root_node
          yield node if block_given?
          keys.each do |key|
            node[key.to_sym] ||= ViewExtension.new                        
            node = node[key.to_sym]
            yield node if block_given?
          end
          node
        end
    
        class ViewExtension < Hash
          attr_reader :partials
          
          def initialize
            super
            @partials = []
          end
          
          def <<(path)
            @partials << path
          end          
        end
      
    end
  end
end 
  