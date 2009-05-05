module RetroI18n  
  class Parser
    attr_reader :paths, :patterns
    
    def initialize(*paths)
      @paths = paths
      @patterns = { :simple => {}, :dynamic => {} }
      parse!
    end
    
    def files
      @files ||= paths.map do |path| 
        Dir.glob(path + '/**/*.*')
      end.flatten.select do |file|
        File.file?(file) && File.readable?(file) && File.size(file) < 10.megabyte
      end.uniq.sort
    end    

    def dump(path)
      patterns.map do |type, strings|
        file = File.join(path, "translations.#{type}.yml")
        File.open(file, 'w+') {|f| YAML.dump(strings.sort_by(&:first), f) }
        file
      end
    end

    protected

      def binary?(content)
        s = content.split(//)
        ((s.size - s.grep(' '..'~').size) / s.size.to_f) > 0.3
      end
      
      def parse!
        files.each do |file|          
          content = File.read(file)
          next if binary?(content)
          
          content.scan(TRANSLATION).each do |match|
            next unless match.first            
            store_pattern!(match.first, file)
          end 
        end
      end

      def store_pattern!(string, file)
        string = clean_pattern(string)
        pattern_type = string =~ DYNAMIC ? :dynamic : :simple
        reference = File.expand_path(file).gsub(/^#{Regexp.escape(RAILS_ROOT)}\/?/, '')
        
        @patterns[pattern_type][string] ||= []
        @patterns[pattern_type][string] << reference
      end

      def clean_pattern(string)
        string[1, string.length-2].gsub(/\\([\'\"])/, '\1')        
      end
    
      TRANSLATION = %r!
        [N]?_
        [\s\(]+?
        [^\\]?((?:\'.*?[^\\]\')|(?:\".*?[^\\]\"))
      !x
    
      DYNAMIC = %r!
        (?:\#\{.+?\})|(^\(.*\)$)
      !x
    
  end  
end