#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
module Retrospectiva
  module Tasks
    CONFIG_FILE = File.join(RAILS_ROOT, 'config', 'runtime', 'tasks.yml')

    class << self
      
      def tasks
        config = load_config
        parsed_tasks.values.each do |task|
          task.apply(config[task.name])
        end
        parsed_tasks.values
      end
      
      def update(values)
        config = load_config.delete_if do |name, |
          not parsed_tasks.key?(name)
        end

        parsed_tasks.values.each do |task|
          config[task.name] ||= {}
          config[task.name][:interval] = values[task.name] || 0
        end
        
        save_config(config)
      end
      
      def load_config
        YAML.load_configuration(Retrospectiva::Tasks::CONFIG_FILE, {})
      end
      private :load_config
      
      def save_config(config)
        File.open(Retrospectiva::Tasks::CONFIG_FILE, 'w') do |f| 
          YAML.dump( config, f )
        end unless RAILS_ENV == 'test'          
      end
      private :save_config

      def parsed_tasks
        @parsed_tasks ||= TaskParser.new.tasks.index_by(&:name)
      end
      private :parsed_tasks
    end

    class TaskParser 
      attr_accessor :last_comment, :tasks, :files

      def initialize 
        @last_comment = ''        
        @tasks = []        
        @files = Dir["#{RAILS_ROOT}/extensions/**/tasks/**/ext_retro_tasks.rake"] + 
                 Dir["#{RAILS_ROOT}/lib/tasks/**/core_retro_tasks.rake"]
        @files.each do |file|
          eval(File.read(file))
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
        self.tasks << FakeTask.new(key.to_s, last_comment, 0, nil, nil)
      end
  
      def desc(comment = '')
        self.last_comment = comment
      end
      
    end


    class FakeTask
      attr_accessor :name, :description, :interval, :started, :last_run

      def initialize(name, description, interval = nil, started = nil, last_run = nil)
        @name, @description, @interval, @started, @last_run = name, description, interval, started, last_run
      end

      def interval
        @interval.to_i
      end
      
      def apply(config)
        config = {} unless config.is_a?(Hash)
        self.interval = config[:interval]
        self.started  = config[:started]
        self.last_run = config[:last_run]        
      end
    end
  end
end
