# coding:utf-8 
module WikiEngine

  class Retro < RedCloth::TextileDoc
    CODE_PATTERN   = /(\s*)\{{3}\n*(.+?)\n*\}{3}/m    
    HEADER_PATTERN = /^(={1,6})[ ]*(.+?)[ ]*=*$/

    module Formatter
      include RedCloth::Formatters::HTML
      
      def clean_html(text, allowed_tags = { 'br' => [] })
        super
      end
    end
  
    def initialize(string)
      super(string.dup, [:sanitize_html, :filter_styles, :filter_classes, :filter_ids])      
      self.hard_breaks = false
      self.no_span_caps = true
      
      # normalize line breaks
      clean_white_space!

      # if entire document is indented, flush
      # to the left side
      flush_left!

      # Extract {{{CODE}}} 
      @code_blocks = {}      
      gsub! CODE_PATTERN do |match|
        placeholder = "((#{ActiveSupport::SecureRandom.hex(20)}))"
        prefix = $1.to_s.empty? ? '' : "\n\n"
        code   = $2.to_s.sub(/\A *[\n\r]+/m, '').sub(/[\n\r]+ *\Z/m, '')
        @code_blocks[placeholder] = ERB::Util.h(code)
        "#{prefix}bc. #{placeholder}\n"
      end
      
      # Rewrite MediaWiki type headers 
      gsub!(HEADER_PATTERN) do |match|
        "h#{$1.size}. #{$2}\n"
      end

      # Rewrite line-breaks 
      gsub!('[[BR]]', '<br />')
    end
    
    # Custom HTML formatter
    def to_html
      to(Formatter).tap do |html|
        @code_blocks.each do |placeholder, code|
          html.sub!(placeholder) { code }
        end
      end
    end

    protected

      def strip_blocks!(*args)
        args.flatten.each do |tag|
          gsub!(/\s*<#{tag}[^>]*>.+?<\/#{tag}[^>]*>\s*/im, ' ')
        end
      end
    
      def clean_white_space!
        gsub!( /\r\n/, "\n" )
        gsub!( /\r/, "\n" )
        gsub!( /\t/, ' ' )
        gsub!( /^ +$/, '' )
        gsub!( /\n{3,}/, "\n\n" )
        gsub!( /"$/, "\" " )
      end
 
      def flush_left!
        indt = 0
        if self =~ /^ /
          while self !~ /^ {#{indt}}\S/
            indt += 1
          end unless empty?
          if indt.nonzero?
            gsub!( /^ {#{indt}}/, '' )
          end
        end
      end

  end
end
