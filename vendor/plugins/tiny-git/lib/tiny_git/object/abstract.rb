module TinyGit
  module Object
    class Abstract
      attr_accessor :objectish, :size, :type, :mode
      
      def initialize(base, objectish)
        @base = base
        @objectish = objectish.to_s
        @contents = nil
        @trees = nil
        @size = nil
        @sha = nil
      end

      def sha
        @sha ||= @base.rev_parse(@objectish)
      end

      def contents
        @contents ||= @base.cat_file(@objectish, :p => true)
      end
      
      def to_s
        @objectish
      end
      
      def tree?; false; end
      
      def blob?; false; end
      
      def commit?; false; end

    end
  end  
end