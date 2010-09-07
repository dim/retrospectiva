module Retrospectiva
  module Previewable
    
    def self.load!
      ActiveSupport::Dependencies.autoload_paths.map do |path|
        Dir[path + '/**/*.rb']
      end.flatten.uniq.each do |file|
        content = File.read(file)
        ActiveSupport::Dependencies.depend_on(file) if content =~ /retro_previewable\s+(do|\{)/
      end
    end
    
    class Base
      
      def initialize(&block)
        @setup = Setup.new(&block)
      end
      
      def channel(options = {})
        Channel.new.tap do |entity|
          @setup.channel.call(entity, options)
        end
      end

      def item(*args)
        Item.new.tap do |entity|
          @setup.item.call(entity, *args)
        end
      end
      
      def channel?
        @setup.channel?
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
  
      def channel?
        @channel.present?
      end
  
      def item(&block)
        @item = block if block_given?
        @item
      end
    end

  end
end
