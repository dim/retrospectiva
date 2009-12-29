module Retrospectiva
  class TaskManager
    class Parser

      attr_accessor :last_comment, :tasks, :files

      def initialize 
        @last_comment = nil        
        @tasks = []        
        @files = Dir["#{RAILS_ROOT}/extensions/**/tasks/**/ext_retro_tasks.rake"] + 
                 Dir["#{RAILS_ROOT}/lib/tasks/**/core_retro_tasks.rake"]
        @files.each do |file|
          instance_eval(File.read(file))
        end
        @tasks = @tasks.sort_by(&:name)
      end
    
      def namespace(name = nil, &block)
        yield if name == :retro        
      end  
    
      def task(*args)
        key = if args.first.is_a?(Hash)
          args.first.keys.first
        else
          args.first
        end
        
        if last_comment
          entry = Task.find_or_create_by_name(key.to_s)
          entry.description = last_comment        
          self.tasks << entry
          self.last_comment = nil
        end
      end
  
      def desc(comment = '')
        self.last_comment = comment
      end

    end
  end
end
