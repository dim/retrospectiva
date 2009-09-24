module TinyGit
  module Object
    class Tree < Abstract
            
      def initialize(base, sha, mode = nil)
        super(base, sha)
        @mode = mode
        @trees = nil
        @blobs = nil
      end
            
      def children
        blobs.merge(subtrees)
      end
      
      def blobs
        check_tree
        @blobs
      end
      alias_method :files, :blobs
      
      def trees
        check_tree
        @trees
      end
      alias_method :subtrees, :trees
      alias_method :subdirectories, :trees
       
      def tree?
        true
      end
       
      private

        # actually run the git command
        def check_tree
          unless @trees
            @trees = {}
            @blobs = {}
            @base.ls_tree(@objectish).each do |hash|
              if hash[:type] == 'tree'
                @trees[hash[:path]] = TinyGit::Object::Tree.new(@base, hash[:sha], hash[:mode])
              elsif hash[:type] == 'blob'
                @trees[hash[:path]] = TinyGit::Object::Blob.new(@base, hash[:sha], hash[:mode])
              end
            end
          end
        end
      
    end
  end  
end