module Retro  
  class Search

    def self.conditions(pattern, *columns)
      new(pattern).to_a(*columns)
    end
  
    def self.exclusive(pattern, *columns)
      return nil if pattern.to_s.blank?
      conditions(pattern, *columns)
    end

    attr_reader :words, :phrases
    def initialize(pattern)
      pattern  = pattern.to_s.dup
      @phrases = extract_phrases!(pattern)
      @words   = extract_words!(pattern)
    end
      
    def tokens
      (words + phrases).uniq
    end
    
    def to_a(*columns)
      raise 'No columns provided' unless columns.any?
      
      [statement(*columns), *variables(*columns)]
    end
  
    def variables(*columns)
      raise 'No columns provided' unless columns.any?
  
      tokens.map do |token|
        columns.map do |column|
          id_column?(column) ? token.to_i : "%#{token}%"
        end
      end.flatten
    end
  
    def statement(*columns)
      raise 'No columns provided' unless columns.any?
  
      tokens.map do |token|
        sql = columns.map do |column|
          if id_column?(column)
            sql_eql(column, token.exclude?)
          else
            sql_like(column, token.exclude?)
          end
        end.join(token.exclude? ? ' AND ' : ' OR ')      
        "(#{sql})"
      end.join(' AND ')    
    end
  
    private
  
      class Token < String
        attr_reader :method_code
  
        def initialize(value)
          @method_code = value.starts_with?('-') ? :x : :i
          super(value.gsub(/^[\+\-]/, '').downcase)
        end
        
        def inspect
          super + "(#{method_code.to_s})"
        end
        
        def exclude?
          method_code == :x
        end
      end
  
      def id_column?(column)
        column.starts_with?('@') or /[._]id\z/ =~ column.to_s
      end

      def sql_eql(column, exclude = false)
        "#{column.gsub(/^@/, '')} #{exclude ? '<>' : '='} ?"
      end  

      def sql_like(column, exclude = false)
        "LOWER(#{column}) #{exclude ? 'NOT ' : ''}LIKE ?"
      end
    
      def extract_phrases!(pattern)
        phrases = []
        pattern.to_s.gsub!(/([\+\-])?\"([^"]*)\"/) do |m|
          phrases << Token.new("#{$1}#{$2}")
          ''
        end
        phrases
      end
  
      def extract_words!(pattern)
        pattern.split(/\s+/).map do |word|
          word.strip!
          word.blank? ? nil : Token.new(word)
        end.compact
      end
        
  end
end
