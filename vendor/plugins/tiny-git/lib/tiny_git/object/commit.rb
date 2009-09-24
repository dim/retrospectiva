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
        
        init_with = @options.delete(:init_with)
        set_commit(init_with) if init_with
      end
      
      def message
        check_commit
        @message
      end
      
      # the first line of the message
      def summary
        @summary ||= message[/[^\n]*/]
      end
      
      def name
        @base.lib.namerev(sha)
      end
      
      def tree
        check_commit
        Tree.new(@base, @tree)
      end
      
      def parent
        parents.first
      end
      
      # array of all parent commits
      def parents
        check_commit
        @parents        
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
      
      def set_commit(data)
        if data['sha']
          @sha = data['sha']
        end
        @committer = TinyGit::Author.new(data['committer'])
        @author = TinyGit::Author.new(data['author'])
        @tree = TinyGit::Object::Tree.new(@base, data['tree'])
        @parents = data['parent'].map{ |sha| TinyGit::Object::Commit.new(@base, sha) }
        @message = data['message'].chomp
        @change_data = data['changes']
        @summary = nil
      end
      
      def commit?
        true
      end

      def changes
        check_commit
        @changes ||= @change_data.map{ |line| TinyGit::Change.parse(line) }.flatten
      end

      private
  
        # see if this object has been initialized and do so if not
        def check_commit
          return if @tree
            
          options = @options.merge(:max_count => 1, :raw => true, :pretty => "format:'#{PRETTY}'")
          lines   = @base.command_lines(:log, @objectish, options)
          hash    = process_commit_data(lines)
          set_commit(hash)
        end
        
        def process_commit_data(lines)
          result = { 'message' => [] }
          ['sha', 'tree', 'parent', 'author', 'committer'].each do |key|
            result[key] = lines.shift
          end

          
          while lines.any?
            line = lines.shift
            break if line.nil? or line =~ /^#{Change::PATTERN}/
            result['message'] << line
          end
          
          result.update( 
            'changes' => lines,
            'parent'  => result['parent'].split(" "), 
            'message' => result['message'].join("\n")
          )  
        end
      
    end
  end  
end