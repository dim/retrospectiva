require 'md5'

unless defined? RedCloth
  $:.unshift(File.dirname(__FILE__))
  require 'base'
end

class RedCloth < String

    DEFAULT_RULES << :docbook

    # == Docbook Rules
    #
    # The following docbook rules can be set individually.  Or add the complete
    # set of rules with the single :docbook rule, which supplies the rule set in
    # the following precedence:
    #
    # refs_docbook::          Docbook references (i.e. [hobix]http://hobix.com/)
    # block_docbook_table::   Docbook table block structures
    # block_docbook_lists::   Docbook list structures
    # block_docbook_prefix::  Docbook blocks with prefixes (i.e. bq., h2., etc.)
    # inline_docbook_image::  Docbook inline images
    # inline_docbook_link::   Docbook inline links
    # inline_docbook_wiki_words:: Docbook inline refering links
    # inline_docbook_wiki_links:: Docbook inline refering links
    # inline_docbook_span::   Docbook inline spans
    # inline_docbook_glyphs:: Docbook entities (such as em-dashes and smart quotes)

    # Elements to handle
    DOCBOOK_GLYPHS = [
        [ /([^\s\[{(>])\'/, '\1&#8217;' ], # single closing
        [ /\'(?=\s|s\b|[#{PUNCT}])/, '&#8217;' ], # single closing
        [ /\'/, '&#8216;' ], # single opening
    #   [ /([^\s\[{(])?"(\s|:|$)/, '\1&#8221;\2' ], # double closing
        [ /([^\s\[{(>])"/, '\1&#8221;' ], # double closing
        [ /"(?=\s|[#{PUNCT}])/, '&#8221;' ], # double closing
        [ /"/, '&#8220;' ], # double opening
        [ /\b( )?\.{3}/, '\1&#8230;' ], # ellipsis
        [ /(\.\s)?\s?--\s?/, '\1&#8212;' ], # em dash
        [ /\s->\s/, ' &rarr; ' ], # right arrow
        [ /\s-\s/, ' &#8211; ' ], # en dash
        [ /(\d+) ?x ?(\d+)/, '\1&#215;\2' ], # dimension sign
        [ /\b ?[(\[]TM[\])]/i, '&#8482;' ], # trademark
        [ /\b ?[(\[]R[\])]/i, '&#174;' ], # registered
        [ /\b ?[(\[]C[\])]/i, '&#169;' ] # copyright
    ]

    #
    # Generates HTML from the Textile contents.
    #
    #   r = RedCloth.new( "And then? She *fell*!" )
    #   r.to_docbook
    #     #=>"And then? She <emphasis role=\"strong\">fell</emphasis>!"
    #
    def to_docbook( *rules )
        @stack = Array.new
        @ids = Array.new
        @references = Array.new
        @automatic_content_ids = Array.new

        rules = DEFAULT_RULES if rules.empty?
        # make our working copy
        text = self.dup
        
        @urlrefs = {}
        @shelf = []
        @rules = rules.collect do |rule|
            case rule
            when :docbook
                DOCBOOK_RULES
            else
                rule
            end
        end.flatten
        
        # standard clean up
        incoming_entities text 
        clean_white_space text 

        # start processor
        @pre_list = []
        pre_process_docbook text

        no_docbook text
        docbook_rip_offtags text
        docbook_hard_break text

        refs text
        docbook_blocks text
        inline text
        
        smooth_offtags text
        retrieve text
        
        post_process_docbook text
        clean_html text if filter_html
        text.strip!
        
        text << "\n"
        @stack.each_with_index {|sect,index| text << "</sect#{@stack.size-index}>\n"}
        text << "</chapter>" if @chapter
        
        if (@references - @ids).size > 0
          text << %{<chapter label="86" id="chapter-86"><title>To Come</title>}
          (@references - @ids).each {|name| text << %!<sect1 id="#{name}"><title>#{name.split('-').map {|t| t.capitalize}.join(' ')}</title><remark>TK</remark></sect1>\n!}
          text << "</chapter>"
        end
        
        text

    end

    #######
    private
    #######

    # Elements to handle
#    GLYPHS << [ /\b([A-Z][A-Z0-9]{2,})\b(?:[(]([^)]*)[)])/, '<acronym title="\2">\1</acronym>' ] # 3+ uppercase acronym
#    GLYPHS << [ /(^|[^"][>\s])([A-Z][A-Z0-9 ]{2,})([^<a-z0-9]|$)/, '\1<span class="caps">\2</span>\3', :no_span_caps ] # 3+ uppercase caps

    SIMPLE_DOCBOOK_TAGS = [
        'para', 'title', 'remark', 'blockquote', 'itemizedlist', 'orderedlist', 'variablelist', 'programlisting', 'screen', 
        'literallayout', 'figure', 'example', 'abbrev', 'accel', 'acronym', 'action', 'application', 'citation',
        'citetitle', 'classname', 'classref', 'command', 'computeroutput', 'email', 'emphasis', 'envar', 'filename',
        'firstterm', 'foreignphrase', 'footnoteref', 'graphic', 'function', 'guibutton', 'guimenu', 'guimenuitem', 'keycap',
        'keysym', 'lineannotation', 'literal', 'option', 'optional', 'parameter', 'prompt', 'quote', 'replaceable',
        'returnvalue', 'sgmltag', 'structfield', 'structname', 'subscript', 'superscript', 'symbol', 'systemitem',
        'type', 'userinput', 'wordasword', 'xref'
    ]

    DOCBOOK_TAGS = [
        ['**', 'emphasis role="strong"'],
        ['__', 'emphasis'],
        ['*',  'emphasis role="strong"', :limit],
        ['_',  'emphasis', :limit],
        ['??', 'citation', :limit],
        ['^',  'superscript', :limit],
        ['~',  'subscript', :limit],
        ['%',  'para', :limit],
        ['@',  'literal', :limit],
    ]
    DOCBOOK_TAGS.collect! do |rc, ht, rtype|
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
    
    def pre_process_docbook(text)
      
      # Prepare dt and dd the way they should be
      text.gsub!( /div\((d[dt])\)\.(.*?)div\(\1\)\./m ) do |m|
        "p(#{$1}). #{$2.gsub("\n", LB)}"
      end
      text.gsub!( /p\(dt\)\.(.*?)p\(dd\)\.(.*?)$/m ) do |m|
        dt, dd = $~[1..2]
        "- #{dt.gsub(LB,"\n").strip} := #{dd.gsub(LB,"\n").strip} =:"
      end
      
      # Prepare superscripts and subscripts
      text.gsub!( /(\w)(\^[0-9,]+\^)/, '\1 \2' )
      text.gsub!( /(\w)(\~[0-9,]+\~)/, '\1 \2' )
      
      {'w' => 'warning', 'n' => 'note', 'c' => 'comment', 'pro' => 'production', 'dt' => 'dt', 'dd' => 'dd'}.each do |char, word|
        parts = text.split(/^\s*#{char}\./)
        text.replace(parts.first + "\n" + parts[1..-1].map do |part|
          if part =~ /\.#{char}\s*$/
            "div(#{word}).\n" + part.sub(/\.#{char}\s*$/, "\ndiv(#{word}). \n")
          else
            "#{char}.#{part}"
          end+"\n"
        end.join("\n"))
        
        self.class.class_eval %!
          def docbook_#{char}(tag, atts, cite, content)
            docbook_p('p', #{word.inspect}, cite, content)
          end
        !
      end

      {'bq' => 'blockquote'}.each do |char, word|
        parts = text.split(/^\s*#{char}\./)
        text.replace(parts.first + "\n" + parts[1..-1].map do |part|
          if part =~ /\.#{char}\s*$/
            "div(#{word}).\n\n<para>" + part.sub(/\.#{char}\s*$/, "</para>\n\ndiv(#{word}). ")
          else
            "#{char}.#{part}"
          end
        end.join("\n"))
      end

      text.gsub!(/<br.*?>/i, "&#x00A;")
      text.gsub!(/<\/?em.*?>/i, "__")

      text.gsub!( BACKTICK_CODE_RE ) do |m|
          before,lang,code,after = $~[1..4]
          docbook_rip_offtags( "#{ before }<programlisting>#{ code.gsub(/\\\`\`\`/,'```') }</programlisting>#{ after }" )
      end
      text.gsub! %r{<pre>\s*(<code>)?}i,       '<para><programlisting>'
      text.gsub! %r{(</code>)?\s*</pre>}i,     '</programlisting></para>'
      text.gsub! %r{<(/?)code>}i,           '<\1programlisting>'
      
    end

    def post_process_docbook( text )
      text.sub!( "</chapter>\n\n", "" )
      text.gsub!( LB, "\n" )
      text.gsub!( NB, "" )
      text << "</#{@div_atts}>" if @div_atts
      text.gsub!(%r{<(#{DOCBOOK_PARAS.join("|")})([^>]*)>\s*<para>(.*?)</para>\s*</\1>}mi) { |m| t, c = $~[1..2]; "<#{t}#{c}>" << $3.gsub(/<para>/, "<#{t}#{c}>").gsub(/<\/para>/, "</#{t}>") << "</#{t}>" }
      text.gsub! %r{<para[^>]*>\s*<para([^>]*)>}i,'<para\1>' # clean multiple paragraphs in a row just in case
      text.gsub! %r{</para>\s*</para>}i,'</para>' # clean multiple paragraphs in a row just in case
      text.gsub! %r{<para[^>]*>\s*</para>\s*}i, '' # clean emtpy paras
      text.gsub! %r{<(/?)sup>}i,            '<\1superscript>'
      text.gsub! %r{<(/?)sub>}i,            '<\1subscript>'
      text.gsub! %r{</?nodocbook>},         ''
      text.gsub! %r{x%x%},                   '&#38;'
      
      text.scan( /id="id([0-9]+)"/i ) do |match|
        text.gsub!( /<ulink url="#{match}">(.*?)<\/ulink>/, %{<link linkend="id#{match}">\\1</link>} )
      end
      
      text.gsub!( %r{<programlisting>\n}, "<programlisting>" )
      text.gsub!( %r{\n</programlisting>}, "</programlisting>\n" )
      
      i = 1
      text.gsub!(/\[\d+\]/) do |ref|
        id = ref[/\d+/].to_i
        if id == i
          i += 1
          if text =~ /<footnote id="fn#{id}">(.*?)<\/footnote>/
            "<footnote id=\"footnote#{id}\">#{$1}</footnote>"
          else
            ref
          end
        else
          ref
        end
      end
      
      text.gsub!(/<footnote id="fn\d+">(.*?)<\/footnote>/, '')
      
      DOCBOOK_TAGS.each do |qtag_rc, ht, qtag_re, rtype, escaped_re|
          text.gsub!( escaped_re ) do |m|
            case rtype
            when :limit
                sta,qtag,atts,cite,content = $~[1..5]
            else
                qtag,atts,cite,content = $~[1..4]
                sta = ''
            end
            
            ht, atts = docbook_sanitize_para atts, content, ht

            atts = docbook_pba( atts )
            
            if @stack.size == 0
              sect1 = ""
              end_sect1 = ""
            end
            
            "#{ sta }#{ sect1 }<#{ ht }#{ atts }>#{ '<para>' if ['note', 'blockquote'].include? ht }#{ cite }#{ content }#{ '</para>' if ['note', 'blockquote'].include? ht }</#{ ht.gsub(/^([^\s]+).*/,'\1') }>#{ end_sect1 }"
          end
      end
    end

    # Parses a Docbook table block, building XML from the result.
    def block_docbook_table( text ) 
        text.gsub!( TABLE_RE ) do |matches|

            caption, id, tatts, fullrow = $~[1..4]
            tatts = docbook_pba( tatts, caption ? 'table' : 'informaltable' )
            tatts = shelve( tatts ) if tatts
            rows = []

            found_first = false
            cols = 0
            raw_rows = fullrow.split( /\|$/m ).delete_if {|row|row.empty?}
            raw_rows.each do |row|

                ratts, row = docbook_pba( $1, 'row' ), $2 if row =~ /^(#{A}#{C}\. )(.*)/m
                row << " "
                
                cells = []
                head = 'tbody'
                cols = row.split( '|' ).size-1
                row.split( '|' ).each_with_index do |cell, i|
                    next if i == 0
                    ctyp = 'entry'
                    head = 'thead' if cell =~ /^_/

                    catts = ''
                    catts, cell = docbook_pba( $1, 'entry' ), $2 if cell =~ /^(_?#{S}#{A}#{C}\. ?)(.*)/

                    catts = shelve( catts ) if catts
                    cells << "<#{ ctyp }#{ catts }>#{ cell.strip.empty? ? "&nbsp;" : row.split( '|' ).size-1 != i ? cell : cell[0...cell.length-1] }</#{ ctyp }>" 
                end
                ratts = shelve( ratts ) if ratts
                if head == 'tbody'
                  if !found_first
                    found_first = true
                    rows << "<#{ head }>"
                  end
                else
                  rows << "<#{ head }>"
                end
                rows << "<row#{ ratts }>\n#{ cells.join( "\n" ) }\n</row>"
                rows << "</#{ head }>" if head != 'tbody' || raw_rows.last == row
            end
            title = "<title>#{ caption }</title>\n" if caption
            
            if id
              @ids << "id#{id}"
              id = " id=\"#{ "id#{id}" }\""
            end
            
            %{<#{ caption ? nil : 'informal' }table#{ id }#{ tatts }>\n#{title}<tgroup cols="#{cols}">\n#{ rows.join( "\n" ) }\n</tgroup>\n</#{ caption ? nil : 'informal' }table>\n\n}
        end
    end
    
    # Parses Docbook lists and generates Docbook XML
    def block_docbook_lists( text )
        orig_text = text.dup
        delimiter = ""
        text.gsub!( LISTS_RE ) do |match|
            lines = match.split( /\n/ )
            last_line = -1
            depth = []
            lines.each_with_index do |line, line_id|
                if line =~ LISTS_CONTENT_RE 
                    tl,continuation,atts,content = $~[1..4]
                    if depth.last
                        if depth.last.length > tl.length
                            (depth.length - 1).downto(0) do |i|
                                break if depth[i].length == tl.length
                                lines[line_id - 1] << "</para></listitem>\n</#{ lD( depth[i] ) }>\n"
                                depth.pop
                            end
                        end
                        if depth.last.length == tl.length
                            lines[line_id - 1] << "</para></listitem>"
                        end
                    end
                    unless depth.last == tl
                        depth << tl
                        atts = docbook_pba( atts )
                        atts = shelve( atts ) if atts
                        delimiter = lD(tl)
                        lines[line_id] = "<#{ delimiter }#{ atts }>\n<listitem><para>#{ content.gsub("<","&lt;").gsub(">","&gt;") }"
                    else
                        lines[line_id] = "<listitem><para>#{ content.gsub("<","&lt;").gsub(">","&gt;") }"
                    end
                    last_line = line_id

                else
                    last_line = line_id
                end
                if line_id - last_line > 1 or line_id == lines.length - 1
                    depth.delete_if do |v|
                        lines[last_line] << "</para></listitem>\n</#{ lD( v ) }>"
                    end
                end
            end
            lines.join( "\n" )
        end
        text != orig_text
    end

    # Parses Docbook lists and generates Docbook XML
    def block_docbook_simple_lists( text )
        orig_text = text.dup
        delimiter = ""
        text.gsub!( LISTS_RE ) do |match|
            lines = match.split( /\n/ )
            last_line = -1
            depth = []
            lines.each_with_index do |line, line_id|
                if line =~ /^([_]+)(#{A}#{C}) (.*)$/m
                    tl,atts,content = $~[1..4]
                    if depth.last
                        if depth.last.length > tl.length
                            (depth.length - 1).downto(0) do |i|
                                break if depth[i].length == tl.length
                                lines[line_id - 1] << "</member>\n</simplelist>\n"
                                depth.pop
                            end
                        end
                        if depth.last.length == tl.length
                            lines[line_id - 1] << "</member>"
                        end
                    end
                    unless depth.last == tl
                        depth << tl
                        atts = docbook_pba( atts )
                        atts = shelve( atts ) if atts
                        lines[line_id] = "<simplelist#{ atts }>\n<member>#{ content.gsub("<","&lt;").gsub(">","&gt;") }"
                    else
                        lines[line_id] = "<member>#{ content.gsub("<","&lt;").gsub(">","&gt;") }"
                    end
                    last_line = line_id

                else
                    last_line = line_id
                end
                if line_id - last_line > 1 or line_id == lines.length - 1
                    depth.delete_if do |v|
                        lines[last_line] << "</member>\n</simplelist>"
                    end
                end
            end
            lines.join( "\n" )
        end
        text != orig_text
    end

    # Parses docbook definition lists and generates HTML
    def block_docbook_defs( text )
        text.gsub!(/^-\s+(.*?):=(.*?)=:\s*$/m) do |m|
          "- #{$1.strip} := <para>"+$2.split(/\n/).map{|w|w.strip}.delete_if{|w|w.empty?}.join("</para><para>")+"</para>"
        end
        
        text.gsub!( DEFS_RE ) do |match|
            lines = match.split( /\n/ )
            lines.each_with_index do |line, line_id|
                if line =~ DEFS_CONTENT_RE 
                    dl,continuation,dt,dd = $~[1..4]
                    
                    atts = pba( atts )
                    atts = shelve( atts ) if atts
                    lines[line_id] = line_id == 0 ? "<variablelist>" : ""
                    lines[line_id] << "\n\t<varlistentry><term>#{ dt.strip }</term>\n\t<listitem><para>#{ dd.strip }</para></listitem></varlistentry>"

                end

                if line_id == lines.length - 1
                    lines[-1] << "\n</variablelist>"
                end
            end
            lines.join( "\n" )
        end
    end
    
    def inline_docbook_code( text ) 
        text.gsub!( CODE_RE ) do |m|
            before,lang,code,after = $~[1..4]
            code = code.gsub(/\\@@?/,'@')
            htmlesc code, :NoQuotes
            docbook_rip_offtags( "#{ before }<literal>#{ shelve code }</literal>#{ after }" )
        end
    end
    
    def lD( text ) 
        text =~ /\#$/ ? 'orderedlist' : 'itemizedlist'
    end

    def docbook_hard_break( text )
        text.gsub!( /(.)\n(?! *[#*\s|]|$)/, "\\1<sbr />" ) if hard_breaks
    end
    
    def docbook_bq( tag, atts, cite, content )
        cite, cite_title = check_refs( cite )
        cite = " citetitle=\"#{ cite }\"" if cite
        atts = shelve( atts ) if atts
        "<blockquote#{ cite }>\n<para>#{ content }</para>\n</blockquote>"
    end

    DOCBOOK_DIVS = ['note', 'blockquote', 'warning']
    def docbook_p( tag, atts, cite, content )
        ht, atts = docbook_sanitize_para atts, content
        atts = docbook_pba( atts )
        atts << " citetitle=\"#{ cite }\"" if cite
        atts = shelve( atts ) if atts
        
        "<#{ ht }#{ atts }>#{ '<para>' if DOCBOOK_DIVS.include? ht }#{ content }#{ '</para>' if DOCBOOK_DIVS.include? ht }</#{ ht.gsub(/^([^\s]+).*/,'\1') }>"
    end
    
    def docbook_div( tag, atts, cite, content, extra_para = true )
        ht, atts = docbook_sanitize_para atts, content
        para, end_para = extra_para || (ht == 'para') ? ["\n<para>", "</para>\n"] : ["", ""]
        return "<#{ ht }#{ atts }>#{ para }#{ content }#{ end_para }</#{ ht.gsub(/^([^\s]+).*/,'\1') }>\n"
    end
    
    def automatic_content_id
      i, new_id = 0, 0
      while new_id == 0 || @automatic_content_ids.include?(new_id)
        j = (i == 0) ? nil : i
        new_id = "S"+MD5.new(@stack.map{|title|title.sub(/^\s*\{\{(.+)\}\}.+/,'\1').strip}.join('-').to_s+j.to_s).to_s
        i += 1
      end
      @automatic_content_ids.push(new_id)
      return new_id
    end
    
    # def docbook_h1, def docbook_h2, def docbook_h3, def docbook_h4
    1.upto 4 do |i|
      class_eval %Q{
        def docbook_h#{i}( tag, atts, cite, content )
          content_id, role = sanitize_content(content)
          
          atts = shelve( atts ) if atts
          end_sections = ''
          @stack.dup.each do |level|
            if @stack.size >= #{i}
              sect = '</sect'
              sect << @stack.size.to_s
              sect << ">\n"
              @stack.pop
              end_sections << sect
            end
          end
          @stack.push sanitized_id_for(content)
          string = end_sections
          string << '<sect#{i} id="'
          string << (content_id.nil? ? automatic_content_id : sanitized_id_for(content_id))
          string << '"'
          if role
            string << ' role="'
            string << role
            string << '"'
          end
          string << '><title>'
          string << content.sub(/^\\s*\\{\\{.+\\}\\}(.+)/,'\\1').strip
          string << '</title>'
        end
      }
    end

    # Handle things like:
    #  ch. 1. Some Title id. 123
    def docbook_ch( tag, atts, cite, content )
      content_id, role = sanitize_content(content)
      
      label, title = content.split('.').map {|c| c.strip}
      
      string = ""
      # Close of the sections in order to end the chapter cleanly
      @stack.each_with_index { |level, index| string << "</sect#{@stack.size-index}>" }
      @stack = []
      
      string << "</chapter>\n\n"
      @chapter = true # let the instance know that a chapter has started
      string << '<chapter label="'
      string << label
      string << '" id="'
      string << (content_id.nil? ? title : sanitized_id_for(content_id))
      string << '"><title>'
      string << title.to_s
      string << '</title>'
      
      return string
    end

    def docbook_fn_( tag, num, atts, cite, content )
        atts << " id=\"fn#{ num }\""
        atts = shelve( atts ) if atts
        "<footnote#{atts}><para>#{ content }</para></footnote>"
    end

    def block_docbook_prefix( text ) 
        if text =~ BLOCK_RE
            tag,tagpre,num,atts,cite,content = $~[1..6]
            atts = docbook_pba( atts )

            # pass to prefix handler
            if respond_to? "docbook_#{ tag }", true
                text.gsub!( $&, method( "docbook_#{ tag }" ).call( tag, atts, cite, content ) )
            elsif respond_to? "docbook_#{ tagpre }_", true
                text.gsub!( $&, method( "docbook_#{ tagpre }_" ).call( tagpre, num, atts, cite, content ) )
            end
        end
    end

    def inline_docbook_span( text )
        DOCBOOK_TAGS.each do |qtag_rc, ht, qtag_re, rtype, escaped_re|
            text.gsub!( qtag_re ) do |m|
             
                case rtype
                when :limit
                    sta,qtag,atts,cite,content = $~[1..5]
                else
                    qtag,atts,cite,content = $~[1..4]
                    sta = ''
                end
                
                ht, atts = docbook_sanitize_para atts, content, ht

                atts = docbook_pba( atts )
                atts << " citetitle=\"#{ cite }\"" if cite
                atts = shelve( atts ) if atts
                
                if @stack.size == 0
                  sect1 = ""
                  end_sect1 = ""
                end
                
                "#{ sta }#{ sect1 }<#{ ht }#{ atts }>#{ '<para>' if ['note', 'blockquote'].include? ht }#{ content }#{ '</para>' if ['note', 'blockquote'].include? ht }</#{ ht.gsub(/^([^\s]+).*/,'\1') }>#{ end_sect1 }"

            end
        end
    end    

    def docbook_lookup_hack(name)
      @book ||= BOOK.inject([]) {|array, chapter| array += chapter[1]}
      @book.index name
    end
    
    def inline_docbook_link( text ) 
        text.gsub!( LINK_RE ) do |m|
            pre,atts,text,title,url,slash,post = $~[1..7]

            url, url_title = check_refs( url )
            title ||= url_title
            
            atts = shelve( atts ) if atts

            "#{ pre }<ulink url=\"#{ url.to_s.gsub('"','&quot;') }#{ slash.to_s.gsub('"','&quot;') }\">#{ text }</ulink>#{ post }"
        end
    end

    DOCBOOK_REFS_RE =  /(^ *)\[([^\[\n]+?)\](#{HYPERLINK})(?=\s|$)/

    def refs_docbook( text ) 
        text.gsub!( DOCBOOK_REFS_RE ) do |m|
            flag, url = $~[2..3]
            @urlrefs[flag.downcase] = [url, nil]
            nil
        end
    end

    def inline_docbook_image( text ) 
        text.gsub!( IMAGE_RE )  do |m|
            stln,algn,atts,url,title,href,href_a1,href_a2 = $~[1..8]
            atts = docbook_pba( atts )
            atts = " fileref=\"#{ url }\"#{ atts }"

            href, alt_title = check_refs( href ) if href
            url, url_title = check_refs( url )

            out = stln
            out << "<figure><title>#{title}</title>\n" if title && !title.empty?
            out << "<graphic#{ shelve( atts ) } />\n"
            out << "</figure>" if title && !title.empty?
            
            out
        end
    end
    
    # Turns all urls into clickable links.
    # Taken from ActionPack's ActionView
    def inline_docbook_autolink_urls(text)
      text.gsub!(AUTO_LINK_RE) do
        all, a, b, c, d = $&, $1, $2, $3, $5
        if a =~ /<a\s/i # don't replace URL's that are already linked
          all
        else
          %(#{a}<ulink url="#{b=="www."?"http://www.":b}#{c}">#{b}#{c}</ulink>#{d})
        end
      end
    end

    # Turns all email addresses into clickable links.
    def inline_docbook_autolink_emails(text)
      text.gsub!(/([\w\.!#\$%\-+.]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)+)/, '<email>\1</email>')
    end
    
    def no_docbook( text )
        text.gsub!( /(^|\s)(\\?)==([^=]+.*?)\2==(\s|$)?/ ) do |m|
          $2.empty? ? "#{$1}<nodocbook>#{$3}</nodocbook>#{$4}" : "#{$1}==#{$3}==#{$4}"
        end
        text.gsub!( /^ *(\\?)==([^=]+.*?)\1==/m ) do |m|
          $1.empty? ? "<nodocbook>#{$2}</nodocbook>" : "==#{$2}=="
        end
    end

    def inline_docbook_glyphs( text, level = 0 )
        if text !~ HASTAG_MATCH
            docbook_pgl text
        else
            codepre = 0
            text.gsub!( ALLTAG_MATCH ) do |line|
                ## matches are off if we're between <code>, <pre> etc.
                if $1
                    if line =~ OFFTAG_OPEN
                        codepre += 1
                    elsif line =~ OFFTAG_CLOSE
                        codepre -= 1
                        codepre = 0 if codepre < 0
                    end 
                elsif codepre.zero?
                    inline_docbook_glyphs( line, level + 1 )
                else
                    htmlesc( line, :NoQuotes )
                end
                ## p [level, codepre, orig_line, line]

                line
            end
        end
    end

    DOCBOOK_OFFTAGS = /(nodocbook|programlisting)/i
    DOCBOOK_OFFTAG_MATCH = /(?:(<\/#{ DOCBOOK_OFFTAGS }>)|(<#{ DOCBOOK_OFFTAGS }[^>]*>))(.*?)(?=<\/?#{ DOCBOOK_OFFTAGS }|\Z)/mi
    DOCBOOK_OFFTAG_OPEN = /<#{ DOCBOOK_OFFTAGS }/
    DOCBOOK_OFFTAG_CLOSE = /<\/?#{ DOCBOOK_OFFTAGS }/

    def docbook_rip_offtags( text )
        if text =~ /<.*>/
            ## strip and encode <pre> content
            codepre, used_offtags = 0, {}
            text.gsub!( DOCBOOK_OFFTAG_MATCH ) do |line|
                if $3
                    offtag, aftertag = $4, $5
                    codepre += 1
                    used_offtags[offtag] = true
                    if codepre - used_offtags.length > 0
                        htmlesc( line, :NoQuotes ) unless used_offtags['nodocbook']
                        @pre_list.last << line
                        line = ""
                    else
                        htmlesc( aftertag, :NoQuotes ) if aftertag and not used_offtags['nodocbook']
                        line = "<redpre##{ @pre_list.length }>"
                        @pre_list << "#{ $3 }#{ aftertag }"
                    end
                elsif $1 and codepre > 0
                    if codepre - used_offtags.length > 0
                        htmlesc( line, :NoQuotes ) unless used_offtags['nodocbook']
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
    
    # In order of appearance: Latin, greek, cyrillian, armenian
    I18N_HIGHER_CASE_LETTERS =
      "√Ä√?√Ç√É√Ñ√ÖƒÄƒÑƒÇ√Ü√áƒÜƒåƒàƒäƒéƒ?√à√â√ä√ãƒíƒòƒöƒîƒñƒúƒûƒ†ƒ¢ƒ§ƒ¶√å√?√é√?ƒ™ƒ®ƒ¨ƒÆƒ∞ƒ≤ƒ¥ƒ∂≈?ƒΩƒπƒªƒø√ë≈É≈á≈Ö≈ä√í√ì√î√ï√ñ√ò≈å≈?≈é≈í≈î≈ò≈ñ≈ö≈†≈û≈ú»ò≈§≈¢≈¶»ö√ô√ö√õ√ú≈™≈Æ≈∞≈¨≈®≈≤≈¥√?≈∂≈∏≈π≈Ω≈ª" + 
      "ŒëŒíŒìŒîŒïŒñŒóŒòŒôŒöŒõŒúŒ?ŒûŒüŒ†Œ°Œ£Œ§Œ•Œ¶ŒßŒ®Œ©" + 
      "ŒÜŒàŒâŒäŒåŒéŒ?—†—¢—§—¶—®—™—¨—Æ—∞—≤—¥—∂—∏—∫—º—æ“Ä“ä“å“é“?“í“î“ñ“ò“ö“ú“û“†“¢“§“¶“®“™“¨“Æ“∞“≤“¥“∂“∏“∫“º“æ”?”É”Ö”á”â”ã”?”?”í”î”ñ”ò”ö”ú”û”†”¢”§”¶”®”™”¨”Æ”∞”≤”¥”∏–ñ" +
      "‘±‘≤‘≥‘¥‘µ‘∂‘∑‘∏‘π‘∫‘ª‘º‘Ω‘æ‘ø’Ä’?’Ç’É’Ñ’Ö’Ü’á’à’â’ä’ã’å’?’?’?’ë’í’ì’î’ï’ñ"

    I18N_LOWER_CASE_LETTERS =
      "√†√°√¢√£√§√•ƒ?ƒÖƒÉ√¶√ßƒáƒ?ƒâƒãƒ?ƒë√®√©√™√´ƒìƒôƒõƒïƒó∆íƒ?ƒüƒ°ƒ£ƒ•ƒß√¨√≠√Æ√Øƒ´ƒ©ƒ≠ƒØƒ±ƒ≥ƒµƒ∑ƒ∏≈Çƒæƒ∫ƒº≈Ä√±≈Ñ≈à≈Ü≈â≈ã√≤√≥√¥√µ√∂√∏≈?≈ë≈?≈ì≈ï≈ô≈ó≈õ≈°≈ü≈?»ô≈•≈£≈ß»õ√π√∫√ª√º≈´≈Ø≈±≈≠≈©≈≥≈µ√Ω√ø≈∑≈æ≈º≈∫√û√æ√ü≈ø√?√∞" +
      "Œ¨Œ≠ŒÆŒØŒ∞Œ±Œ≤Œ≥Œ¥ŒµŒ∂Œ∑Œ∏ŒπŒ∫ŒªŒºŒΩŒæŒøœÄœ?œÇœÉœÑœÖœÜœáœàœâœäœãœåœ?œéŒ?" +
      "–∞–±–≤–≥–¥–µ–∂–∑–∏–π–∫–ª–º–Ω–æ–ø—Ä—?—Ç—É—Ñ—Ö—Ü—á—à—â—ä—ã—å—?—é—?—?—ë—í—ì—î—ï—ñ—ó—ò—ô—õ—ú—?—û—ü—°—£—•—ß—©—´—≠—Ø—±—≥—µ—∑—π—ª—Ω—ø“?“ã“?“?“ë“ì“ï“ó“ô“õ“?“ü“°“£“•“ß“©“´“≠“Ø“±“≥“µ“∑“π“ª“Ω“ø”Ä”Ç”Ñ”Ü”à”ä”å”é”ë”ì”ï”ó”ô”õ”?”ü”°”£”•”ß”©”´”≠”Ø”±”≥”µ”π" +
      "’°’¢’£’§’•’¶’ß’®’©’™’´’¨’≠’Æ’Ø’∞’±’≤’≥’¥’µ’∂’∑’∏’π’∫’ª’º’Ω’æ’ø÷Ä÷?÷Ç÷É÷Ñ÷Ö÷Ü÷á"

    WIKI_WORD_PATTERN = '[A-Z' + I18N_HIGHER_CASE_LETTERS + '][a-z' + I18N_LOWER_CASE_LETTERS + ']+[A-Z' + I18N_HIGHER_CASE_LETTERS + ']\w+'
    CAMEL_CASED_WORD_BORDER = /([a-z#{I18N_LOWER_CASE_LETTERS}])([A-Z#{I18N_HIGHER_CASE_LETTERS}])/u

    WIKI_WORD = Regexp.new('(":)?(\\\\)?(' + WIKI_WORD_PATTERN + ')\b', 0, "utf-8")

    WIKI_LINK = /(":)?\[\[([^\]]+)\]\]/
    
    def inline_docbook_wiki_words( text )
      text.gsub!( WIKI_WORD ) do |m|
        textile_link_suffix, escape, page_name = $~[1..3]
        if escape.nil? && textile_link_suffix !=~ /https?:\/\/[^\s]+$/
          "#{textile_link_suffix}<xref linkend=\"#{ sanitized_reference_for page_name }\"></xref>"
        else
          "#{textile_link_suffix}#{page_name}"
        end
      end
    end

    def inline_docbook_wiki_links( text )
      text.gsub!( WIKI_LINK ) do |m|
        textile_link_suffix, content_id = $~[1..2]
        "#{textile_link_suffix}<xref linkend=\"#{ sanitized_reference_for "id#{content_id}" }\"></xref>"
      end
    end
    
    # Search and replace for glyphs (quotes, dashes, other symbols)
    def docbook_pgl( text )
        DOCBOOK_GLYPHS.each do |re, resub, tog|
            next if tog and method( tog ).call
            text.gsub! re, resub
        end
    end

    # Parses attribute lists and builds an HTML attribute string
    def docbook_pba( text_in, element = "" )
        
        return '' unless text_in

        style = []
        text = text_in.dup
        if element == 'td'
            colspan = $1 if text =~ /\\(\d+)/
            rowspan = $1 if text =~ /\/(\d+)/
        end

        style << "#{ $1 };" if not filter_styles and
            text.sub!( /\{([^}]*)\}/, '' )

        lang = $1 if
            text.sub!( /\[([^)]+?)\]/, '' )

        cls = $1 if
            text.sub!( /\(([^()]+?)\)/, '' )
                        
        cls, id = $1, $2 if cls =~ /^(.*?)#(.*)$/
        
        atts = ''
        atts << " role=\"#{ cls }\"" unless cls.to_s.empty?
        atts << " id=\"#{ id }\"" if id
        atts << " colspan=\"#{ colspan }\"" if colspan
        atts << " rowspan=\"#{ rowspan }\"" if rowspan
        
        atts
    end
    
    def sanitize_content( text="" )
      text.replace text[/(.*?) role\. (\w+)/] ? $1 : text
      role = $2
      text.replace text[/(.*?) id\. ([0-9]+)/] ? $1 : text
      content_id = $2 ? "id#{$2}" : nil
      return content_id, role
    end

    def sanitized_id_for( text )
      word = text.gsub(CAMEL_CASED_WORD_BORDER, '\1 \2').downcase.gsub(/\s/,'-').gsub(/[^A-Za-z0-9\-\{\}]/,'').sub(/^[^\w\{]*/, '')
      @ids << word unless @ids.include? word
      return word
    end
    
    def sanitized_reference_for( text )
      word = text.gsub(CAMEL_CASED_WORD_BORDER, '\1 \2').downcase.gsub(/\s/,'-').gsub(/[^A-Za-z0-9\-\{\}]/,'').sub(/^[^\w\{]*/, '')
      @references << word unless @references.include? word
      return word
    end
    
    DOCBOOK_PARAS = ['para', 'remark', 'tip', 'important']
    def docbook_blocks( text, deep_code = false )
      @current_class ||= nil
      
      # Find all occurences of div(class). and process them as blocks
      text.gsub!( /^div\((.*?)\)\.\s*(.*?)(?=div\([^\)]+\)\.\s*)/m ) do |blk|
        block_class = (@current_class == $1) ? nil : %{ role=#{$1.inspect}}
        @current_class = $1
        BLOCK_GROUP_SPLITTER + ( ($2.strip.empty? || block_class.nil?) ? $2 : docbook_div('div', block_class, nil, "\n\n#{$2.strip}\n\n", false) )
      end
      
      # Take care of the very last div
      text.sub!( /div\((.*?)\)\.\s*(.*)/m ) do |blk|
        block_class = (@current_class == $1) ? nil : %{ role=#{$1.inspect}}
        @current_class = $1
        BLOCK_GROUP_SPLITTER + ( ($2.strip.empty? || block_class.nil?) ? $2 : docbook_div('div', block_class, nil, "\n\n#{$2.strip}\n\n", false) )
      end
      
      # Handle the text now that the placeholders for divs are set, splitting at BLOCK_GROUP_SPLITTER
      text.replace(text.strip.split(BLOCK_GROUP_SPLITTER.strip).map do |chunk|
        tag, tag_name, para, body, end_para, end_tag = $~[1..6] if chunk.strip =~ %r{(<(#{(DOCBOOK_PARAS+DOCBOOK_DIVS).join("|")}).*?>)\s*(<para[^>]*>)?\s*(.*?)\s*(</para>)?\s*(</\2>)}m
        
        if tag && chunk.strip.split[0][/<.*?>/] == tag
          if DOCBOOK_PARAS.include? tag_name
            tag = "#{para}#{tag}"
            end_tag = "#{end_para}#{end_tag}"
          end
          body = docbook_block_groups(body, deep_code)
          body = "\n"+body.strip+"\n" unless DOCBOOK_PARAS.include? tag_name
          
          tag + body + end_tag + "\n"
        else
          docbook_block_groups(chunk, deep_code)
        end
      end.join)
    end
    
    def docbook_block_groups( text, deep_code = false )
      text.replace text.split( BLOCKS_GROUP_RE ).collect { |blk| docbook_blk(blk, deep_code) }.join("\n")
    end

    def docbook_blk( text, deep_code = false )
      return text if text =~ /<[0-9]+>/
      
      plain = text !~ /\A[#*> ]/

      # skip blocks that are complex HTML
      if text =~ /^<\/?(\w+).*>/ and not SIMPLE_DOCBOOK_TAGS.include? $1
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
                  docbook_blocks iblk, plain
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
                      text = "<para><programlisting>#{ text }</programlisting></para>" # unless text =~ /list>/
                  else
                      text = "<para>#{text}</para>\n"
                  end
              end
              # hard_break text
              text << "\n#{ code_blk }"
          end
          return text
      end
    end

    def docbook_sanitize_para(atts, content, ht = "para")
      case atts
      when /comment/
        ht = "remark"
        atts = nil
      when /preface/
        ht = "preface"
        atts = nil
      when /blockquote/
        ht = "blockquote"
        atts = nil
      when /warning/
        ht = "warning"
        atts = nil
      when /note/
        ht = "note"
        atts = nil
      when /tip/
        ht = "tip"
        atts = nil
      when /important/
        ht = "important"
        atts = nil
      when /filename/
        ht = "filename"
        atts = nil
      when /production/
        ht = "remark"
        atts = nil
      when /xref/
        if content =~ /^(.*)\[Hack \#(.*)\]$/
          name = $2
          ht = %Q{link linkend="#{sanitized_reference_for name}"}
          content.gsub!( /^(.*)\s\[Hack \#(.*)\]$/, '\1' )
        else
          ht = %Q{xref linkend="#{sanitized_reference_for content}"}
          content.replace ''
        end
        atts = nil
      when /synopsis/
        ht = "para"
        atts = %{ role="hack synopsis"}
      when /author/
        ht = "para"
        atts = %{ role="hacks-contributor"}
      when /technical/
        ht = "command"
        atts = nil
      end
      return ht, atts
    end

end
