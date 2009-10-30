module TinyGit  
  module Commands    

    def ls_tree(sha, *arguments)
      arguments.unshift(sha)
      command_lines(:ls_tree, *arguments).map do |line|
        (info, path) = line.split("\t")
        (mode, type, sha) = info.split        
        {:sha => sha, :path => unescape(path), :type => type, :mode => mode}
      end
    end

    def rev_parse(*arguments)
      command(:rev_parse, *arguments).chomp
    end
    
    def rev_list(sha, *arguments)
      arguments.unshift(sha)
      command_lines(:rev_list, *arguments)
    end

    def cat_file(sha, *arguments)
      arguments.unshift(sha)
      result = command(:cat_file, *arguments)
      result =~ /\A[^\n]+\n\Z/m ? result.chomp : result
    end

    def log(range, *arguments)
      arguments.unshift(range)
      command(:log, *arguments)      
    end

    def command_lines(*args)
      command(*args).split("\n")
    end
    
    def command(cmd, *args)
      opt_args = transform_options(args.extract_options!)
      ext_args = args.reject { |a| a.empty? }.map { |a| (a == '--' || a[0].chr == '|') ? a : escape(a) }

      call = "#{TinyGit.git_binary} --git-dir=#{escape(self.git_dir)} #{cmd.to_s.gsub(/_/, '-')} #{(opt_args + ext_args).join(' ')}"
      run_command(call)
    end

    private
      
      def run_command(call)
        output = ''
        
        seconds = Benchmark.realtime do
          output = `#{call} 2>&1`
        end
        status  = exit_status($?, output)
        raise_execution_error(status, output, call) unless status.zero?
        
        @logger.debug "  TinyGit (#{sprintf("%.1f", seconds * 1000)}ms) #{call}" if @logger
        output
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
            value == true ? "-#{option}" : "-#{option} #{value}" 
          else
            value == true ? "--#{option}" : "--#{option}=#{value}"           
          end
        end
      end

      def escape(s)
        s.to_s.inspect
      end

      UNESCAPE_MAP = { '\\\\' => '\\', '\\"'  => '"' }
      
      def unescape(s)
        return s unless s =~ /["]/ 
        s.gsub(/^["]/, '').gsub(/["]$/, '').gsub(/(\\\\|\\["])/) { UNESCAPE_MAP[$1] }
      end

      def raise_execution_error(status, output, call)
        raise TinyGit::GitExecuteError.new(status, output, call)        
      end

      def exit_status(status, out)
        return 0 unless status.is_a?(Process::Status)
        
        s = status.exitstatus.to_i
        s.zero? || ( s == 1 && out.blank? ) ? 0 : s 
      end

  end  
end
