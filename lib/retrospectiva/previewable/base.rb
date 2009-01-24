module Retrospectiva
  module Previewable
    
    class Base      
      def initialize(&block)
        @setup = Setup.new(&block)
      end
      
      def channel(options = {})
        returning(Channel.new) do |entity|
          @setup.channel.call(entity, options)
        end
      end

      def item(*args)
        returning(Item.new) do |entity|
          @setup.item.call(entity, *args)
        end
      end
    end
    
    class Setup
      def initialize(&block)
        yield self
      end

      def channel(&block)
        @channel = block if block_given?
        @channel
      end
  
      def item(&block)
        @item = block if block_given?
        @item
      end
    end

  end
end
