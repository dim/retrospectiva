require 'redcloth_ng'

class RetroMarkup < RedCloth

  private
    
    class RetroString < String
      
      def mgsub(key_value_pairs = [].freeze)
        regexp_fragments = key_value_pairs.collect { |k,v| k }
        gsub(Regexp.union(*regexp_fragments)) do |match|
          match.gsub(*(key_value_pairs.detect{|k,v| k =~ match}))
        end  
      end
    
      def mgsub!(key_value_pairs = [].freeze)
        replace(mgsub(key_value_pairs))
      end
      
    end

    
  public  

    def initialize( string )    
      self.filter_html    = true
      self.filter_styles  = true
      self.hard_breaks    = false
      self.no_span_caps   = true  
      super( string )
    end
    
    def to_html
      save_self = self.dup
      clean_white_space self
  
      # Extract {{{code}}} parts, no more processing on them
      code_parts = {}
      self.gsub!(%r{\{\{\{\n*(.+?)\n*\}\}\}}um) do |match|
        key = "{\0#{code_parts.size}\0}"
        regexp = '(<p[^>]*>)*\s*' + Regexp.escape(key) + '\s*(<\/p[^>]*>)*'
        code_parts[Regexp.new(regexp)] = "<pre><code>#{CGI.escapeHTML($1)}</code></pre>"
        "\n\n#{key}\n\n"
      end

      evil = %w(meta i?frame i?layer app\w* link object embed bgsound form input select textarea style script)
      
      # Remove evil HTML blocks with content
      strip_blocks! evil

      # Remove evil HTML tags (captures invalid HTML markup)
      strip_tags! evil

      # Remove ALL valid HTML tags
      strip_all_tags!

      # Convert all MediaWiki style headers
      convert_mediawiki_headers!
             
      html = RetroString.new(super(:textile))
      self.replace(save_self)

      # Convert all [[BR]] to real line breaks
      html.gsub!(%r{\[\[BR\]\]}, '<br/>')     
      
      # Insert {{{code}}} parts again
      html.mgsub!(code_parts)
      
      html
    end

  private
  
    def strip_blocks!(*args)
      args.flatten.each do |tag|
        gsub!(%r{<#{tag}[^>]*>.+?<\/#{tag}[^>]*>}im, '')        
      end
    end

    def strip_tags!(*args)
      args.flatten.each do |tag|
        gsub!(%r{<[ /]*#{args.flatten[1]}[^<>]*}im, '')        
      end
    end

    def strip_all_tags!(*args)     
      gsub!( /<!\[CDATA\[/, '' )
      gsub!( /<\/*[A-Za-z]\w*[^>]*["'\w]\/?>/, '' )    
    end

    MediaWikiHeadersRE = %r{^
      (={1,6})       # $1 => string of ='s
      [ ]*
      (.+?)           # $2 => Header text
      [ ]*
      =*             # optional closing ='s (not counted)      
    $}x

    def convert_mediawiki_headers!
      gsub!(MediaWikiHeadersRE) do |match|
        i = $1.size
        "h#{i}. #{$2}\n"
      end
    end

    TEXTILE_REFS_REX =  /(^ *)\[([^\[\n]+?)\](#{HYPERLINK})(?=\s|$)/

    def refs_textile( text ) 
      text.gsub!( TEXTILE_REFS_REX ) do |m|
        flag, url = $~[2..3]
        @urlrefs[flag.downcase] = [url, nil]
        nil
      end
    end

    QTAGSX = [
      ['**', 'b'],
      ['*', 'strong'],
      ['\'\'', 'cite', :limit],
      ['-', 'del', :limit],
      ['++', 'i'],
      ['+', 'em', :limit],
      ['%', 'span', :limit],
      ['_', 'ins', :limit],
      ['^', 'sup'],
      ['~', 'sub']
    ] 
    
    QTAGSX.collect! do |rc, ht, rtype|
      rcq = Regexp::quote rc
      re =
        case rtype
        when :limit
          /(\W)(#{rcq})(#{C})(?::(\S+?))?(\S|\S.*?\S)#{rcq}(?=\W)/x
        else
          /(#{rcq})(#{C})(?::(\S+))?(\S|\S.*?\S)#{rcq}/xm 
        end
      [rc, ht, re, rtype]
    end

    def inline_textile_span( text ) 
      QTAGSX.each do |qtag_rc, ht, qtag_re, rtype|
        text.gsub!( qtag_re ) do |m|
           
          case rtype
          when :limit
            sta,qtag,atts,cite,content = $~[1..5]
          else
            qtag,atts,cite,content = $~[1..4]
            sta = ''
          end
          atts = pba( atts )
          atts << " cite=\"#{ cite }\"" if cite
          atts = shelve( atts ) if atts

          "#{ sta }<#{ ht }#{ atts }>#{ content }</#{ ht }>"

        end
      end
    end
    
    def textile_bc( tag, atts, cite, content )
      "\t<pre><code#{ atts }>#{ content }</code></pre>" 
    end

    def inline_textile_autolink_urls(text)
      text.gsub!(AUTO_LINK_RE) do
        all, a, b, c, d = $&, $1, $2, $3, $4
        if a =~ /<a\s/i # don't replace URL's that are already linked
          all
        else
          %(#{a}<a href="#{b=="www."?"http://www.":b}#{c}">#{b}#{c}</a>#{d})
        end
      end
    end
      
end
