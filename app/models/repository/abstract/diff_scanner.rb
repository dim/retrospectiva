class Repository::Abstract::DiffScanner 
  attr_reader :header, :blocks
  
  def initialize(unified_diff)
    @header, *parts = unified_diff.split(marker_pattern)
    @blocks = (0..(parts.size/3-1)).map do |index|
      Block.new(*parts[index*3, 3])
    end
  end

  def source_rev
    @source_rev ||= [header.scan(source_revision_pattern)].flatten.compact.first
  end

  def target_rev
    @target_rev ||= [header.scan(target_revision_pattern)].flatten.compact.first
  end
  
  def marker_pattern
    /^@@ -(\d+),?\d* \+(\d+),?\d* @@\s/
  end

  def source_revision_pattern
    /^\-{3} Revision (\w+)$/
  end

  def target_revision_pattern
    /^\+{3} Revision (\w+)$/
  end
  
  
  protected
  
    class Block        
      attr_reader :start_ln1, :start_ln2, :segments
      
      def initialize(start_ln1, start_ln2, content)
        @start_ln1 = start_ln1.to_i
        @start_ln2 = start_ln2.to_i
  
        @segments = []
        content.split(/\r?\n/).each do |line, index|
          klass = case line.first when '+', '-' then Update when ' ' then Copy else nil end
          next if klass.blank?
          
          @segments << klass.new unless segments.last.is_a?(klass)
          @segments.last << line
        end
      end
  
      def lines
        n1, n2 = start_ln1 - 1, start_ln2 - 1
  
        segments.map do |segment|
          set = if segment.is_a?(Update)
            segment.deletes.map {|l| Line.new(l, n1 += 1) } +
            segment.inserts.map {|l| Line.new(l, nil, n2 += 1) }
          else
            segment.lines.map {|l| Line.new(l, n1 += 1, n2 += 1) }
          end
          LineSet.new(set, segment.name)          
        end
      end
  
      def line_pairs
        n1, n2 = start_ln1 - 1, start_ln2 - 1
        
        segments.map do |segment|
          set = if segment.is_a?(Update)                            
            deletes = segment.deletes.map {|l| Line.new(l, n1 += 1) }                            
            deletes << Line.new('', nil) while deletes.size < segment.size
            
            inserts = segment.inserts.map {|l| Line.new(l, n2 += 1) }                            
            inserts << Line.new('', nil) while inserts.size < segment.size

            deletes.zip(inserts)              
          else          
            segment.lines.map do |l|
              [Line.new(l, n1 += 1), Line.new(l, n2 += 1)]
            end
          end
          LineSet.new(set, segment.name)          
        end
      end

      def inspect
        "#<#{self.class.name} [#{start_ln1}:#{start_ln2}] @segments=#{segments.inspect}>"
      end
    end
  
    class Segment
      def <<(line)
        raise 'Abstract method'
      end        
      
      def info
        raise 'Abstract method'
      end        
      
      def name
        self.class.name.demodulize.downcase
      end
      
      def inspect
        "#<S:#{name}: #{info}>"
      end
    end
    
    class Copy < Segment
      attr_reader :lines
  
      def initialize
        super
        @lines = []
      end
  
      def <<(line)
        @lines << line
      end        
      
      def info
        lines.size.to_s
      end
    end
    
    class Update < Segment
      attr_reader :deletes, :inserts
      
      def initialize
        super
        @deletes, @inserts = [], []
      end
      
      def <<(line)          
        line.starts_with?('+') ? @inserts << line : @deletes << line
      end
      
      def name
        super + ' ' + detail
      end
      
      def detail
        deletes.size.zero? ? 'insert' : ( inserts.size.zero? ? 'delete' : 'modify' )
      end
      
      def info
        "#{deletes.size}/#{inserts.size}"
      end
      
      def size
        [deletes.size, inserts.size].max
      end
    end
    
    class LineSet < Array
      attr_reader :operation
      def initialize(array, operation)
        @operation = operation
        super(array)        
      end

      # Flatten only once
      def flatten
        inject([]) do |result, items|
          [*items].each {|i| result << i }
          result
        end
      end
    end
    
    class Line < String
      attr_reader :n1, :n2
      
      def initialize(value, n1, n2 = nil)
        @n1, @n2 = n1, n2
        super(value.gsub(/^./, ''))
      end
    end 
      
end