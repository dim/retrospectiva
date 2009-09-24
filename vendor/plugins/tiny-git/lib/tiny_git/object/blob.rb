module TinyGit
  module Object
    class Blob < Abstract
      
      def initialize(base, sha, mode = nil)
        super(base, sha)
        @mode = mode
      end
      
      def size
        return contents.size if @contents
        @size ||= @base.cat_file(@objectish, :s => true).to_i        
      end
      
      def blob?
        true
      end

    end
  end  
end