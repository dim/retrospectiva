module Grit
  
  class Git
    class GitTimeout < RuntimeError
      attr_reader :command, :bytes_read

      def initialize(command = nil, bytes_read = nil)
        @command = command
        @bytes_read = bytes_read
      end
    end

    undef_method :clone
    
    class << self
      attr_accessor :git_binary, :git_timeout, :git_max_size
    end
  
    self.git_binary   = "/usr/bin/env git"
    self.git_timeout  = 10
    self.git_max_size = 5242880 # 5.megabytes
    
    def self.with_timeout(timeout = 10.seconds)
      old_timeout = Grit::Git.git_timeout
      Grit::Git.git_timeout = timeout
      yield
      Grit::Git.git_timeout = old_timeout
    end
    
    attr_accessor :git_dir, :bytes_read
    
    def initialize(git_dir)
      self.git_dir    = git_dir
      self.bytes_read = 0
    end
    
    def shell_escape(str)
      str.to_s.gsub(/([^A-Za-z0-9_\-.,:\/@\n\ %])/n, "\\\\\\1").gsub(/\n/, "'\n'")
    end
    alias_method :e, :shell_escape
    
    # Run the given git command with the specified arguments and return
    # the result as a String
    #   +cmd+ is the command
    #   +options+ is a hash of Ruby style options
    #   +args+ is the list of arguments (to be joined by spaces)
    #
    # Examples
    #   git.rev_list({:max_count => 10, :header => true}, "master")
    #
    # Returns String
    def method_missing(cmd, options = {}, *args)
      run('', cmd, '', options, args)
    end

    def run(prefix, cmd, postfix, options, args)
      timeout  = options.delete(:timeout) rescue nil
      timeout  = true if timeout.nil?

      opt_args = transform_options(options)
      ext_args = args.reject { |a| a.empty? }.map { |a| (a == '--' || a[0].chr == '|') ? a : "'#{e(a)}'" }

      call = "#{prefix}#{Git.git_binary} --git-dir='#{self.git_dir}' #{cmd.to_s.gsub(/_/, '-')} #{(opt_args + ext_args).join(' ')}#{e(postfix)}"
      execute(call, timeout)
    end
    
    def execute(call, timeout = nil)
      out, err = nil, nil
      
      seconds = Benchmark.realtime do
        out, err = timeout ? sh(call) : wild_sh(call)      
      end
      seconds = "(#{sprintf("%.1f", seconds * 1000)}ms)"
      
      Grit.logger.debug "  Grit #{seconds}  #{call}"
      
      if Grit.debug
        Grit.logger.debug "  Grit STDOUT  #{out}" 
        Grit.logger.debug "  Grit STDERR  #{err}"
      end

      out
    end

    def sh(command)
      ret, err = '', ''
      Open3.popen3(command) do |_, stdout, stderr|
        Timeout.timeout(self.class.git_timeout) do
          while tmp = stdout.read(1024)
            ret += tmp
            if (@bytes_read += tmp.size) > self.class.git_max_size
              bytes = @bytes_read
              @bytes_read = 0
              raise GitTimeout.new(command, bytes)
            end
          end
        end

        while tmp = stderr.read(1024)
          err += tmp
        end
      end
      [ret, err]
    rescue Timeout::Error, Grit::Git::GitTimeout
      bytes = @bytes_read
      @bytes_read = 0
      raise GitTimeout.new(command, bytes)
    end

    def wild_sh(command)
      ret, err = '', ''
      Open3.popen3(command) do |_, stdout, stderr|
        while tmp = stdout.read(1024)
          ret += tmp
        end

        while tmp = stderr.read(1024)
          err += tmp
        end
      end
      [ret, err]
    end

    # Transform Ruby style options into git command line options
    #   +options+ is a hash of Ruby style options
    #
    # Returns String[]
    #   e.g. ["--max-count=10", "--header"]
    def transform_options(options)
      options.inject([]) do |result, (option, value)|
        option = option.to_s.gsub(/_/, '-')
        
        result << if option.size == 1
          value == true ? "-#{option}" : "-#{option} '#{e(value)}'" 
        else
          value == true ? "--#{option}" : "--#{option}='#{e(value)}'"           
        end
      end
    end

  end # Git
  
end # Grit
