module TinyGit
  module Object
    class Commit < Abstract
      PRETTY = %Q(%H%n%T%n%P%n%an <%ae> %aD%n%cn <%ce> %cD%n%s%n%b)
      
      def initialize(base, sha, options = {})
        super(base, sha)
        
        @tree = nil
        @parents = nil
        @author = nil
        @committer = nil
        @message = nil
        @options = options.dup
        @checked = false
        
        set_commit(@options.delete(:init))
      end
      
      def message
        check_commit
        @message.join("\n").chomp
      end
      
      # the first line of the message
      def summary
        check_commit
        @message.first
      end
      
      def tree
        check_commit
        @tree ||= Tree.new(@base, @tree_data)
      end
      
      def parent
        parents.first
      end
      
      # array of all parent commits
      def parents
        check_commit
        @parents ||= @parent_data.map{ |sha| TinyGit::Object::Commit.new(@base, sha) }        
      end
      
      # true if this is a merge commit
      # (i.e. it has more than one parent)
      def merge?
        parents.size > 1
      end
            
      def author     
        check_commit
        @author
      end
      
      def committer
        check_commit
        @committer
      end
      
      def date 
        committer.date
      end
      
      def commit?
        true
      end

      def changes
        check_commit
        @changes ||= @change_data.map{ |line| TinyGit::Change.parse(line) }.flatten
      end

      private
  
        def set_commit(data)
          return if data.nil?
          
          @sha = data['sha'] if data['sha']
          @committer   = TinyGit::Author.new(data['committer'])
          @author      = TinyGit::Author.new(data['author'])
          @message     = data['message']
          @parent_data = data['parent']
          @tree_data   = data['tree']
          @change_data = data['changes']
          @checked     = true
        end
        
        # see if this object has been initialized and do so if not
        def check_commit
          return if @checked
            
          options = @options.merge(:max_count => 1, :raw => true, :pretty => "format:'#{PRETTY}'")
          lines   = @base.command_lines(:log, @objectish, options)
          hash    = process_commit_data(lines)
          set_commit(hash)
        end
        
        def process_commit_data(lines)
          result = { 'message' => [], 'changes' => [] }
          ['sha', 'tree', 'parent', 'author', 'committer'].each do |key|
            result[key] = lines.shift
          end

          lines.each do |line|
            result[line =~ /^#{Change::PATTERN}/ ? 'changes' : 'message'] << line 
          end
          
          result.update('parent'  => result['parent'].split(" "))  
        end
      
    end
  end  
end