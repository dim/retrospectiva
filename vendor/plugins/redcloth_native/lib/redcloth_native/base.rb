class RedCloth < String

    VERSION = '3.0.4'
    DEFAULT_RULES = [] # let each class add to this array
    TEXTILE_RULES = [:refs_textile, :block_textile_table, :block_textile_lists, :block_textile_defs,
                     :block_textile_prefix, :inline_textile_image, :inline_textile_link,
                     :inline_textile_code, :inline_textile_span, :glyphs_textile,
                     :inline_textile_autolink_urls, :inline_textile_autolink_emails]
    MARKDOWN_RULES = [:refs_markdown, :block_markdown_setext, :block_markdown_atx, :block_markdown_rule,
                      :block_markdown_bq, :block_markdown_lists, 
                      :inline_markdown_reflink, :inline_markdown_link]
    DOCBOOK_RULES = [:refs_docbook, :block_docbook_table, :block_docbook_lists, :block_docbook_simple_lists,
                     :block_docbook_defs, :block_docbook_prefix, :inline_docbook_image, :inline_docbook_link,
                     :inline_docbook_code, :inline_docbook_glyphs, :inline_docbook_span,
                     :inline_docbook_wiki_words, :inline_docbook_wiki_links, :inline_docbook_autolink_urls,
                     :inline_docbook_autolink_emails]
    @@escape_keyword ||= "redcloth"
    
    #
    # Accessors for setting security restrictions.
    #
    # This is a nice thing if you're using RedCloth for
    # formatting in public places (e.g. Wikis) where you
    # don't want users to abuse HTML for bad things.
    #
    # If +:filter_html+ is set, HTML which wasn't
    # created by the Textile processor will be escaped.
    # Alternatively, if +:sanitize_html+ is set, 
    # HTML can pass through the Textile processor but
    # unauthorized tags and attributes will be removed.
    #
    # If +:filter_styles+ is set, it will also disable
    # the style markup specifier. ('{color: red}')
    #
    # If +:filter_classes+ is set, it will also disable
    # class attributes. ('!(classname)image!')
    #
    # If +:filter_ids+ is set, it will also disable
    # id attributes. ('!(classname#id)image!')
    #
    attr_accessor :filter_html, :sanitize_html, :filter_styles, :filter_classes, :filter_ids

    #
    # Accessor for toggling hard breaks.
    #
    # If +:hard_breaks+ is set, single newlines will
    # be converted to HTML break tags.  This is the
    # default behavior for traditional RedCloth.
    #
    attr_accessor :hard_breaks

    # Accessor for toggling lite mode.
    #
    # In lite mode, block-level rules are ignored.  This means
    # that tables, paragraphs, lists, and such aren't available.
    # Only the inline markup for bold, italics, entities and so on.
    #
    #   r = RedCloth.new( "And then? She *fell*!", [:lite_mode] )
    #   r.to_html
    #   #=> "And then? She <strong>fell</strong>!"
    #
    attr_accessor :lite_mode

    #
    # Accessor for toggling span caps.
    #
    # Textile places `span' tags around capitalized
    # words by default, but this wreaks havoc on Wikis.
    # If +:no_span_caps+ is set, this will be
    # suppressed.
    #
    attr_accessor :no_span_caps

    #
    # Establishes the markup predence.
    #
    attr_accessor :rules

    # Returns a new RedCloth object, based on _string_ and
    # enforcing all the included _restrictions_.
    #
    #   r = RedCloth.new( "h1. A <b>bold</b> man", [:filter_html] )
    #   r.to_html
    #     #=>"<h1>A &lt;b&gt;bold&lt;/b&gt; man</h1>"
    #
    def initialize( string, restrictions = [] )
        restrictions.each { |r| method( "#{ r }=" ).call( true ) }
        super( string )
    end

    #
    # Generates HTML from the Textile contents.
    #
    #   r = RedCloth.new( "And then? She *fell*!" )
    #   r.to_html( true )
    #     #=>"And then? She <strong>fell</strong>!"
    #
    def to_html( *rules )
        rules = DEFAULT_RULES if rules.empty?
        # make our working copy
        text = self.dup
        
        return "" if text == ""

        @urlrefs = {}
        @shelf = []
        @rules = rules.collect do |rule|
            case rule
            when :markdown
                MARKDOWN_RULES
            when :textile
                TEXTILE_RULES
            else
                rule
            end
        end.flatten

        # standard clean up
        @pre_list = []
        pre_process text
        DEFAULT_RULES.each {|ruleset| send("#{ruleset}_pre_process", text) if private_methods.include? "#{ruleset}_pre_process"}
        incoming_entities text 
        clean_white_space text 

        # start processor
        no_textile text
        rip_offtags text
        if filter_html
          escape_html_tags text
        elsif sanitize_html
          clean_html text
        end
        hard_break text
        unless @lite_mode
            refs text
            blocks text
        end
        inline text

        escape_html_except_tags text if filter_html || sanitize_html

        smooth_offtags text
        retrieve text

        post_process text
        DEFAULT_RULES.each {|ruleset| send("#{ruleset}_post_process", text) if private_methods.include? "#{ruleset}_post_process"}

        return text.strip

    end

    #######
    private
    #######
    #
    # Regular expressions to convert to HTML.
    #
    LB = "0docbook0line0break0"
    NB = "0docbook0no0break0\n\n"
    A_HLGN = /(?:(?:<>|<|>|\=|[()]+)+)/
    A_VLGN = /[\-^~]/
    C_CLAS = '(?:\([^)]+\))'
    C_LNGE = '(?:\[[^\]]+\])'
    C_STYL = '(?:\{[^}]+\})'
    S_CSPN = '(?:\\\\\d+)'
    S_RSPN = '(?:/\d+)'
    A = "(?:#{A_HLGN}?#{A_VLGN}?|#{A_VLGN}?#{A_HLGN}?)"
    S = "(?:#{S_CSPN}?#{S_RSPN}|#{S_RSPN}?#{S_CSPN}?)"
    C = "(?:#{C_CLAS}?#{C_STYL}?#{C_LNGE}?|#{C_STYL}?#{C_LNGE}?#{C_CLAS}?|#{C_LNGE}?#{C_STYL}?#{C_CLAS}?)"
    PUNCT = Regexp::quote( '!"#$%&\'*+,-./:;=?@\\^_`|~' )
    PUNCT_NOQ = Regexp::quote( '!"#$&\',./:;=?@\\`|' )
    PUNCT_Q = Regexp::quote( '*-_+^~%' )
    HYPERLINK = '(\S+?)([^\w\s/;=\?]*?)(?=\s|<|$)'
    
    TABLE_RE = /^(?:caption ?\{(.*?)\}\. ?\n)?^(?:id ?\{(.*?)\}\. ?\n)?^(?:table(_?#{S}#{A}#{C})\. ?\n)?^(#{A}#{C}\.? ?\|.*?\|)(\n\n|\Z)/m
    LISTS_RE = /^([#*_0-9]+?#{C} .*?)$(?![^#*])/m
    LISTS_CONTENT_RE = /^([#*]+)([_0-9]*)(#{A}#{C}) (.*)$/m
    DEFS_RE = /^(-#{C}\s.*?\:\=.*?)$(?![^-])/m
    DEFS_CONTENT_RE = /^(-)(#{A}#{C})\s+(.*?):=(.*)$/m
    BACKTICK_CODE_RE = /(.*?)
        ```
        (?:\|(\w+?)\|)?
        (.*?[^\\])
        ```
        (.*?)/mx
    CODE_RE = /(.*?)
        @@?
        (?:\|(\w+?)\|)?
        (.*?[^\\])
        @@?
        (.*?)/x
    BLOCKS_GROUP_RE = /\n{2,}(?! )/m
    BLOCK_RE = /^(([a-z]+)(\d*))(#{A}#{C})\.(?::(\S+))? (.*)$/
    SETEXT_RE = /\A(.+?)\n([=-])[=-]* *$/m
    ATX_RE = /\A(\#{1,6})  # $1 = string of #'s
              [ ]*
              (.+?)       # $2 = Header text
              [ ]*
              \#*         # optional closing #'s (not counted)
              $/x
    LINK_RE = /
            ([\s\[{(]|[#{PUNCT}])?     # $pre
            "                          # start
            (#{C})                     # $atts
            ([^"]+?)                   # $text
            \s?
            (?:\(([^)]+?)\)(?="))?     # $title
            ":
            ([^\s<]+?)                 # $url
            (\/)?                      # $slash
            ([^\w\/;]*?)               # $post
            (?=<|\s|$)
        /x 
    IMAGE_RE = /
            (<p>|.|^)            # start of line?
            \!                   # opening
            (\<|\=|\>)?          # optional alignment atts
            (#{C})               # optional style,class atts
            (?:\. )?             # optional dot-space
            ([^\s(!]+?)          # presume this is the src
            \s?                  # optional space
            (?:\(((?:[^\(\)]|\([^\)]+\))+?)\))?   # optional title
            \!                   # closing
            (?::#{ HYPERLINK })? # optional href
        /x 

    # Text markup tags, don't conflict with block tags
    SIMPLE_HTML_TAGS = [
        'tt', 'b', 'i', 'big', 'small', 'em', 'strong', 'dfn', 'code',
        'samp', 'kbd', 'var', 'cite', 'abbr', 'acronym', 'a', 'img', 'br',
        'br', 'map', 'q', 'sub', 'sup', 'span', 'bdo'
    ]

    QTAGS = [
        ['**', 'b'],
        ['*', 'strong'],
        ['??', 'cite', :limit],
        ['-', 'del', :limit],
        ['__', 'i'],
        ['_', 'em', :limit],
        ['%', 'span', :limit],
        ['+', 'ins', :limit],
        ['^', 'sup'],
        ['~', 'sub']
    ]
    QTAGS.collect! do |rc, ht, rtype|
        rcq = Regexp::quote rc
        re =
            case rtype
            when :limit
                /(\W)
                (#{rcq})
                (#{C})
                (?::(\S+?))?
                (\S.*?\S|\S)
                #{rcq}
                (?=\W)/x
            else
                /(#{rcq})
                (#{C})
                (?::(\S+))?
                (\S.*?\S|\S)
                #{rcq}/xm 
            end
        escaped_re =
            case rtype
            when :limit
                /(\W)
                (#{@@escape_keyword}#{rcq})
                (#{C})
                (?::(\S+?))?
                (\S.*?\S|\S)
                #{rcq}#{@@escape_keyword}
                (?=\W)/x
            else
                /(#{@@escape_keyword}#{rcq})
                (#{C})
                (?::(\S+))?
                (\S.*?\S|\S)
                #{rcq}#{@@escape_keyword}/xm
            end
        [rc, ht, re, rtype, escaped_re]
    end

    # Elements to handle
    GLYPHS = [
    #   [ /([^\s\[{(>])?\'([dmst]\b|ll\b|ve\b|\s|:|$)/, '\1&#8217;\2' ], # single closing
        [ /([^\s\[{(>#{PUNCT_Q}][#{PUNCT_Q}]*)\'/, '\1&#8217;' ], # single closing
        [ /\'(?=[#{PUNCT_Q}]*(s\b|[\s#{PUNCT_NOQ}]))/, '&#8217;' ], # single closing
        [ /\'/, '&#8216;' ], # single opening
    #   [ /([^\s\[{(])?"(\s|:|$)/, '\1&#8221;\2' ], # double closing
        [ /([^\s\[{(>#{PUNCT_Q}][#{PUNCT_Q}]*)"/, '\1&#8221;' ], # double closing
        [ /"(?=[#{PUNCT_Q}]*[\s#{PUNCT_NOQ}])/, '&#8221;' ], # double closing
        [ /"/, '&#8220;' ], # double opening
        [ /\b( )?\.{3}/, '\1&#8230;' ], # ellipsis
        [ /\b([A-Z][A-Z0-9]{2,})\b(?:[(]([^)]*)[)])/, '<acronym title="\2">\1</acronym>' ], # 3+ uppercase acronym
        [ /(^|[^"][>\s])([A-Z][A-Z0-9 ]+[A-Z0-9])([^<A-Za-z0-9]|$)/, '\1<span class="caps">\2</span>\3', :no_span_caps ], # 3+ uppercase caps
        [ /(\.\s)?\s?--\s?/, '\1&#8212;' ], # em dash
        [ /(^|\s)->(\s|$)/, ' &rarr; ' ], # right arrow
        [ /(^|\s)-(\s|$)/, ' &#8211; ' ], # en dash
        [ /(\d+) ?x ?(\d+)/, '\1&#215;\2' ], # dimension sign
        [ /\b ?[(\[]TM[\])]/i, '&#8482;' ], # trademark
        [ /\b ?[(\[]R[\])]/i, '&#174;' ], # registered
        [ /\b ?[(\[]C[\])]/i, '&#169;' ] # copyright
    ]

    H_ALGN_VALS = {
        '<' => 'left',
        '=' => 'center',
        '>' => 'right',
        '<>' => 'justify'
    }

    V_ALGN_VALS = {
        '^' => 'top',
        '-' => 'middle',
        '~' => 'bottom'
    }

    OFFTAGS = /(code|pre|kbd|notextile)/i
    OFFTAG_MATCH = /(?:(<\/#{ OFFTAGS }>)|(<#{ OFFTAGS }[^>]*>))(.*?)(?=<\/?#{ OFFTAGS }|\Z)/mi
    OFFTAG_OPEN = /<#{ OFFTAGS }/
    OFFTAG_CLOSE = /<\/?#{ OFFTAGS }/
    
    HASTAG_MATCH = /(<\/?\w[^\n]*?>)/m
    ALLTAG_MATCH = /(<\/?\w[^\n]*?>)|.*?(?=<\/?\w[^\n]*?>|$)/m
    
    def pre_process( text )
      text.gsub!( /={2}\`\`\`={2}/, "XXXpreformatted_backticksXXX" )
    end
    
    def post_process( text )
      text.gsub!( /XXXpreformatted_backticksXXX/, '```' )
      text.gsub!( LB, "\n" )
      text.gsub!( NB, "" )
      text.gsub!( /<\/?notextile>/, '' )
      text.gsub!( /x%x%/, '&#38;' )
      text << "</div>" if @div_atts
    end
    
    # Search and replace for glyphs (quotes, dashes, other symbols)
    def pgl( text )
        GLYPHS.each do |re, resub, tog|
            next if tog and method( tog ).call
            text.gsub! re, resub
        end
    end

    # Parses attribute lists and builds an HTML attribute string
    def pba( text_in, element = "" )
        
        return '' unless text_in

        style = []
        text = text_in.dup
        if element == 'td'
            colspan = $1 if text =~ /\\(\d+)/
            rowspan = $1 if text =~ /\/(\d+)/
            style << "vertical-align:#{ v_align( $& ) };" if text =~ A_VLGN
        end

        style << "#{ $1 };" if not filter_styles and
            text.sub!( /\{([^}]*)\}/, '' )

        lang = $1 if
            text.sub!( /\[([^)]+?)\]/, '' )

        cls = $1 if
            text.sub!( /\(([^()]+?)\)/, '' )
                        
        style << "padding-left:#{ $1.length }em;" if
            text.sub!( /([(]+)/, '' )

        style << "padding-right:#{ $1.length }em;" if text.sub!( /([)]+)/, '' )

        style << "text-align:#{ h_align( $& ) };" if text =~ A_HLGN

        cls, id = $1, $2 if cls =~ /^(.*?)#(.*)$/
        
        atts = ''
        atts << " style=\"#{ style.join }\"" unless style.empty?
        atts << " class=\"#{ cls }\"" unless cls.to_s.empty? or filter_classes
        atts << " lang=\"#{ lang }\"" if lang
        atts << " id=\"#{ id }\"" if id and not filter_ids
        atts << " colspan=\"#{ colspan }\"" if colspan
        atts << " rowspan=\"#{ rowspan }\"" if rowspan
        
        atts
    end

    #
    # Flexible HTML escaping
    #
    def htmlesc( str, mode=nil )
        str.gsub!( '&', '&amp;' )
        str.gsub!( '"', '&quot;' ) if mode != :NoQuotes
        str.gsub!( "'", '&#039;' ) if mode == :Quotes
        str.gsub!( '<', '&lt;')
        str.gsub!( '>', '&gt;')
    end

    def hard_break( text )
        text.gsub!( /(.)\n(?!\n|\Z| *([#*=]+(\s|$)|[{|]))/, "\\1<br />" ) if hard_breaks
    end

    def lT( text ) 
        text =~ /\#$/ ? 'o' : 'u'
    end

    BLOCK_GROUP_SPLITTER = "XXX_BLOCK_GROUP_XXX\n\n"
    def blocks( text, deep_code = false )
      @current_class ||= nil
      
      # Find all occurences of div(class). and process them as blocks
      text.gsub!( /^div\((.*?)\)\.\s*(.*?)(?=div\([^\)]+\)\.\s*)/m ) do |blk|
        block_class = (@current_class == $1) ? nil : %{ class=#{$1.inspect}}
        @current_class = $1
        BLOCK_GROUP_SPLITTER + ( ($2.strip.empty? || block_class.nil?) ? $2 : textile_p('div', block_class, nil, "\n\n#{$2.strip}\n\n") )
      end
      
      # Take care of the very last div
      text.sub!( /div\((.*?)\)\.\s*(.*)/m ) do |blk|
        block_class = (@current_class == $1) ? nil : %{ class=#{$1.inspect}}
        @current_class = $1
        BLOCK_GROUP_SPLITTER + ( ($2.strip.empty? || block_class.nil?) ? $2 : textile_p('div', block_class, nil, "\n\n#{$2.strip}\n\n") )
      end
      
      # Handle the text now that the placeholders for divs are set, splitting at BLOCK_GROUP_SPLITTER
      text.replace(text.strip.split(BLOCK_GROUP_SPLITTER.strip).map do |chunk|
        block_groups(chunk, deep_code)
      end.join)
    end
    
    def block_groups( text, deep_code = false )
      text.replace text.split( BLOCKS_GROUP_RE ).collect { |blk| blk(blk, deep_code) }.join("\n")
    end

    # Surrounds blocks with paragraphs and shelves them when necessary
    def blk( text, deep_code = false )
      return text if text =~ /<[0-9]+>/
      
      plain = text !~ /\A[#*> ]/

      # skip blocks that are complex HTML
      if text =~ /^<\/?(\w+).*>/ and not SIMPLE_HTML_TAGS.include? $1
          text
      else
          # search for indentation levels
          text.strip!
          if text.empty?
              text
          else
              code_blk = nil
              text.gsub!( /((?:\n(?:\n^ +[^\n]*)+)+)/m ) do |iblk|
                  flush_left iblk
                  blocks iblk, plain
                  iblk.gsub( /^(\S)/, "\\1" )
                  if plain
                      code_blk = iblk; ""
                  else
                      iblk
                  end
              end
              block_applied = 0 
              @rules.each do |rule_name|
                  block_applied += 1 if ( rule_name.to_s.match /^block_/ and method( rule_name ).call( text ) )
              end
              if block_applied.zero?
                if deep_code
                    text = "\t<pre><code>#{ text }</code></pre>\n"
                else
                    text = "\t<p>#{ text }</p>\n"
                end
              end
              # hard_break text
              text << "\n#{ code_blk }"
          end
          return text
      end
      
    end
    
    def refs( text )
        @rules.each do |rule_name|
            method( rule_name ).call( text ) if rule_name.to_s.match /^refs_/
        end
    end

    def check_refs( text ) 
        ret = @urlrefs[text.downcase] if text
        ret || [text, nil]
    end
    
    # Puts text in storage and returns is placeholder
    #  e.g. shelve("some text") => <1>
    def shelve( val ) 
        @shelf << val
        " <#{ @shelf.length }>"
    end
    
    # Retrieves text from storage using its placeholder
    #  e.g. retrieve("<1>") => "some text"
    def retrieve( text ) 
        @shelf.each_with_index do |r, i|
            text.gsub!( " <#{ i + 1 }>" ){|m| r }
        end
    end

    def incoming_entities( text ) 
        ## turn any incoming ampersands into a dummy character for now.
        ## This uses a negative lookahead for alphanumerics followed by a semicolon,
        ## implying an incoming html entity, to be skipped

        text.gsub!( /&(?!(?:[a-zA-Z0-9]+|\#[0-9]+|\#x[0-9a-fA-F]+);)/i, "x%x%" )
    end

    def clean_white_space( text ) 
        # normalize line breaks
        text.gsub!( /\r\n/, "\n" )
        text.gsub!( /\r/, "\n" )
        text.gsub!( /\t/, '    ' )
        text.gsub!( /^ +$/, '' )
        text.gsub!( /\n{3,}/, "\n\n" )
        text.gsub!( /"$/, "\" " )

        # if entire document is indented, flush
        # to the left side
        flush_left text
    end

    def flush_left( text )
        indt = 0
        if text =~ /^ /
            while text !~ /^ {#{indt}}\S/
                indt += 1
            end unless text.empty?
            if indt.nonzero?
                text.gsub!( /^ {#{indt}}/, '' )
            end
        end
    end

    def footnote_ref( text ) 
        text.gsub!( /\b\[([0-9]+?)\](\s)?/,
            '<sup><a href="#fn\1">\1</a></sup>\2' )
    end

    def rip_offtags( text )
        if text =~ /<.*>/
            ## strip and encode <pre> content
            codepre, used_offtags = 0, {}
            text.gsub!( OFFTAG_MATCH ) do |line|
                if $3
                    offtag, aftertag = $4, $5
                    codepre += 1
                    used_offtags[offtag] = true
                    if codepre - used_offtags.length > 0
                        htmlesc( line, :NoQuotes ) unless used_offtags['notextile']
                        @pre_list.last << line
                        line = ""
                    else
                        htmlesc( aftertag, :NoQuotes ) if aftertag and not used_offtags['notextile']
                        line = "<redpre##{ @pre_list.length }>"
                        @pre_list << "#{ $3 }#{ aftertag }"
                    end
                elsif $1 and codepre > 0
                    if codepre - used_offtags.length > 0
                        htmlesc( line, :NoQuotes ) unless used_offtags['notextile']
                        @pre_list.last << line
                        line = ""
                    end
                    codepre -= 1 unless codepre.zero?
                    used_offtags = {} if codepre.zero?
                end 
                line
            end
        end
        text
    end

    def smooth_offtags( text )
        unless @pre_list.empty?
            ## replace <pre> content
            text.gsub!( /<redpre#(\d+)>/ ) { @pre_list[$1.to_i] }
        end
    end

    def inline( text ) 
        [/^inline_/, /^glyphs_/].each do |meth_re|
            @rules.each do |rule_name|
                method( rule_name ).call( text ) if rule_name.to_s.match( meth_re )
            end
        end
    end

    def h_align( text ) 
        H_ALGN_VALS[text]
    end

    def v_align( text ) 
        V_ALGN_VALS[text]
    end

    # HTML cleansing stuff
    BASIC_TAGS = {
        'a' => ['href', 'title'],
        'img' => ['src', 'alt', 'title'],
        'br' => [],
        'i' => nil,
        'u' => nil, 
        'b' => nil,
        'pre' => nil,
        'kbd' => nil,
        'code' => ['lang'],
        'cite' => nil,
        'strong' => nil,
        'em' => nil,
        'ins' => nil,
        'sup' => nil,
        'sub' => nil,
        'del' => nil,
        'table' => nil,
        'tr' => nil,
        'td' => ['colspan', 'rowspan'],
        'th' => nil,
        'ol' => ['start'],
        'ul' => nil,
        'li' => nil,
        'p' => nil,
        'h1' => nil,
        'h2' => nil,
        'h3' => nil,
        'h4' => nil,
        'h5' => nil,
        'h6' => nil, 
        'blockquote' => ['cite']
    }
    
    # Clean unauthorized tags.
    def clean_html( text, allowed_tags = BASIC_TAGS )
        text.gsub!( /<!\[CDATA\[/, '' )
        text.gsub!( /<(\/*)([A-Za-z]\w*)([^>]*?)(\s?\/?)>/ ) do |m|
            raw = $~
            tag = raw[2].downcase
            if m =~ /<redpre#\d+>/
              m # return internal pre markers untouched
            elsif allowed_tags.has_key? tag
                pcs = [tag]
                allowed_tags[tag].each do |prop|
                    ['"', "'", ''].each do |q|
                        q2 = ( q != '' ? q : '\s' )
                        if raw[3] =~ /#{prop}\s*=\s*#{q}([^#{q2}]+)#{q}/i
                            attrv = $1
                            next if (prop == 'src' or prop == 'href') and not attrv =~ %r{^(http|https|ftp):}
                            pcs << "#{prop}=\"#{attrv.gsub('"', '\\"')}\""
                            break
                        end
                    end
                end if allowed_tags[tag]
                "<#{raw[1]}#{pcs.join " "}#{raw[4]}>"
            else # Unauthorized tag
              if block_given?
                yield m
              else
                ''
              end
            end
        end
    end
    
    # Which tags to accept as input when :filter_html is on
    ALLOWED_INCOMING_TAGS = {
        'kbd' => nil,
        'code' => ['lang'],
        'notextile' => nil, 
        'pre' => nil
    }
    
    def escape_html_tags(text)
      clean_html(text, ALLOWED_INCOMING_TAGS) do |m|
        htmlesc(m) # gsub!s m
        m
      end
    end
    
    def escape_html_except_tags(text)
      text.gsub!(/
          ( <!-- (?m:.*?) -->
            | <\/? 
              [A-Za-z]\w*\b                               # Tags start with a letter and
              (?:<\d+>|[^>"']|"[^"]*"|'[^']*')* >         # can have shelved items or HTML attributes.
            | &(?:[a-zA-Z0-9]+|\#[0-9]+|\#x[0-9a-fA-F]+); # Existing entity.
          )
          |([^<&]+|[<&])

        /x) do |m|
          if $2
            htmlesc(m)
            m
          else
            m
          end
      end
    end
    
    AUTO_LINK_RE = /
                    (                       # leading text
                      <\w+.*?>|             #   leading HTML tag, or
                      [^=!:'"\/]|           #   leading punctuation, or 
                      ^                     #   beginning of line
                    )
                    (
                      (?:http[s]?:\/\/)|    # protocol spec, or
                      (?:www\.)             # www.*
                    ) 
                    (
                      ([\w]+[=?&:%\/\.\~\-]*)*    # url segment
                      \w+[\/]?              # url tail
                      (?:\#\w*)?            # trailing anchor
                    )
                    ([[:punct:]]|\s|<|$)    # trailing text
                   /x unless Object.const_defined?('AUTO_LINK_RE')

end

