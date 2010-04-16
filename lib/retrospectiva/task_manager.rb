require 'retrospectiva/task_manager/task'
require 'retrospectiva/task_manager/parser'
require 'fileutils'

module Retrospectiva
  class TaskManager

    attr_reader :logger
    
    def initialize
      @logger = ActiveSupport::BufferedLogger.new(File.join(RAILS_ROOT, 'log', 'tasks.log'), ActiveSupport::BufferedLogger::INFO)
    end
    
    def pending
      @pending ||= tasks.select(&:pending?)      
    end
    
    def tasks
      @tasks ||= Task.all
    end
    
    def run
      return if pending.empty?
      
      load File.join(RAILS_ROOT, 'Rakefile')
      
      pending.each do |task|
        rake_task = Rake.application.lookup("retro:#{task.name}")
        unless rake_task
          logger.error "[!] No rake task for '#{task.name}'"
          next
        end
  
        task.log_run(logger) do
          rake_task.invoke        
        end
      end
    end
    
  end  
end
