module Retrospectiva
  module Previewable  
        
    mattr_accessor :class_names
    self.class_names = []

    def self.register(*klasses)
      klasses.flatten.each do |klass|
        class_names << klass.name unless class_names.include?(klass.name)
      end
    end
    
    def self.klasses
      class_names.map(&:constantize).select do |klass|
        klass.previewable.channel?
      end
    end
    
    module Extension
      
      def self.included(base)
        base.extend ClassMethods
      end
    
      module ClassMethods
        def retro_previewable(&block)
          @previewable = Retrospectiva::Previewable::Base.new(&block)
          include InstanceMethods
          extend SingletonMethods          
          Retrospectiva::Previewable.register(self)
        end
      end

      module SingletonMethods
        def previewable
          @previewable
        end
        
        def searchable?
          respond_to?(:full_text_search)
        end

        def feedable?
          respond_to?(:feedable)
        end

        def to_rss(records, options = {})
          RSS::Maker.make('2.0') do |rss|
            previewable.channel(options).apply_to!(rss.channel)
            records.each do |record|
              record.to_rss(rss.items.new_item, options)
            end
            rss.items.do_sort = true
          end
        end
      end
      
      module InstanceMethods

        def previewable(options = {})
          self.class.previewable.item(self, options)
        end
        
        def to_rss(builder_item, options)
          previewable(options).apply_to!(builder_item)
        end
        
      end
      
    end    
  end
end
