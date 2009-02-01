module Retrospectiva
  module Previewable

    class AbstractEntity
      include ActionController::UrlWriter
      attr_reader :attributes
      
      def initialize
        @attributes = {}
      end      

      def method_missing(method, *args)
        if getter?(method)
          attributes[method.to_s]
        elsif setter?(method)
          attributes[name_only(method)] = args.first
        else 
          super
        end          
      end

      def respond_to?(method)
        getter?(method) || setter?(method) || super
      end
      
      def apply_to!(other)
        attributes.each do |k, v|
          other.send("#{k}=".to_sym, v) if other.respond_to?("#{k}=".to_sym)
        end
      end

      def path
        return nil unless getter?(:link) and link.present?
        
        pattern = Regexp.escape(URI.parse(link).path)
        link.gsub(/^.*(#{pattern}.*)$/, '\1')
      end
      
      def route(*args)
        send(*args)
      end
      
      protected

        def getter?(method)
          valid_attribute_names.include?(method.to_sym)
        end

        def setter?(method)
          method.to_s.ends_with?('=') && valid_attribute_names.include?(name_only(method).to_sym)
        end
        
        def name_only(method)
          method.to_s.gsub(/=$/, '')
        end

        def valid_attribute_names
          []
        end      
    end

    class Channel < AbstractEntity
      
      def eql?(other)
        other.class == self.class and name == other.name
      end
      alias_method :==, :eql?
      
      def inspect
        "#<Channel name: #{name}, title: #{title}, link: #{link}>"
      end

      protected
        def valid_attribute_names
          [:title, :description, :link, :name]
        end      
    end

    class Item < AbstractEntity
      protected
        def valid_attribute_names
          [:title, :description, :link, :date, :guid, :author, :comments]
        end      
    end
    
  end
end
