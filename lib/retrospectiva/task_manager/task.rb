module Retrospectiva
  class TaskManager
    class Task < ActiveRecord::Base
      configuration = ERB.new(File.read(RAILS_ROOT + '/config/database.yml'))
      establish_connection YAML.load(configuration.result)[RAILS_ENV]
  
      validates_presence_of :name, :started_at, :finished_at
      validates_uniqueness_of :name
      validates_numericality_of :interval, 
        :integer_only => true,
        :greater_or_equal => 0        

      attr_accessor :description
  
      def self.create_or_update(name, interval = 0)
        record   = find_by_name(name)
        interval = interval.to_i
        
        if record
          record.update_attributes :interval => interval
          record
        else
          create :name => name, :interval => interval          
        end
      end
  
      # Is the task due and ready?
      def pending?
        due? and ready?
      end
  
      # Is the task running?
      def running?
        started_at > finished_at 
      end    
      
      def active?
        interval > 59
      end
      
      # Is the task ready to run?
      def ready?
        active? and not running? 
      end
      
      def stale?
        running? and started_at < 10.minutes.ago
      end

      # Is the task due to run?
      def due?
        due_at.to_i <= current_minute.to_i
      end

      def unused?
        current_minute.to_i - due_at.to_i > 120        
      end

      def log_run(logger)
        update_attribute :started_at, Time.now.utc
        logger.info "[+] #{started_at} | Started #{name}"
        begin
          yield
        rescue Exception => exception
          log_exception(logger, exception)
        ensure
          update_attribute :finished_at, Time.now.utc        
          logger.info "[=] #{finished_at} | Finished #{name}"
        end
      end      
      
      def due_at
        finished_at + interval
      end

      private

        def current_minute
          now = Time.now.utc
          now -= now.sec
        end
    
        def log_exception(logger, exception)
          clean_trace = exception.backtrace.map do |line| 
            line.gsub(RAILS_ROOT, '')
          end
          
          logger.fatal(
            "\n    #{exception.class} (#{exception.message}):\n    " +
            clean_trace.join("\n    ") +
            "\n"
          )
        end      

    end
  end
end
