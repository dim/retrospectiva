unless defined? RedCloth
  $:.unshift(File.dirname(__FILE__))
  require 'base'
end

class RedCloth < String

    DEFAULT_RULES << :textile

    #
    # == Textile Rules
    #
    # The following textile rules can be set individually.  Or add the complete
    # set of rules with the single :textile rule, which supplies the rule set in
    # the following precedence:
    #
    # refs_textile::          Textile references (i.e. [hobix]http://hobix.com/)
    # block_textile_table::   Textile table block structures
    # block_textile_lists::   Textile list structures
    # block_textile_prefix::  Textile blocks with prefixes (i.e. bq., h2., etc.)
    # block_textile_defs::    Textile definition lists
    # inline_textile_image::  Textile inline images
    # inline_textile_link::   Textile inline links
    # inline_textile_span::   Textile inline spans
    # glyphs_textile::        Textile entities (such as em-dashes and smart quotes)
    #
    
    #######
    private
    #######
    #
    # Mapping of 8-bit ASCII codes to HTML numerical entity equivalents.
    # (from PyTextile)
    #
    TEXTILE_TAGS =

        [[128, 8364], [129, 0], [130, 8218], [131, 402], [132, 8222], [133, 8230], 
         [134, 8224], [135, 8225], [136, 710], [137, 8240], [138, 352], [139, 8249], 
         [140, 338], [141, 0], [142, 0], [143, 0], [144, 0], [145, 8216], [146, 8217], 
         [147, 8220], [148, 8221], [149, 8226], [150, 8211], [151, 8212], [152, 732], 
         [153, 8482], [154, 353], [155, 8250], [156, 339], [157, 0], [158, 0], [159, 376]].

        collect! do |a, b|
            [a.chr, ( b.zero? and "" or "&##{ b };" )]
        end
    
    def textile_pre_process(text)
      {'w' => 'warning', 'n' => 'note', 'c' => 'comment', 'pro' => 'production', 'dt' => 'dt', 'dd' => 'dd'}.each do |char, word|
        parts = text.split(/^\s*#{char}\./)
        text.replace(parts.first + "\n" + parts[1..-1].map do |part|
          if part =~ /\.#{char}\s*$/
            "div(#{word})." + part.sub(/\.#{char}\s*$/, "div(#{word}). \n")
          else
            "#{char}.#{part}"
          end
        end.join("\n"))
        
        self.class.class_eval %!
          def textile_#{char}(tag, atts, cite, content)
            textile_p('p', %{ class=#{word.inspect}}, cite, content)
          end
        !
      end
      {'bq' => 'blockquote'}.each do |char, word|
        parts = text.split(/^\s*#{char}\./)
        text.replace(parts.first + "\n" + parts[1..-1].map do |part|
          if part =~ /\.#{char}\s*$/
            "div(#{word})." + part.sub(/\.#{char}\s*$/, "div(#{word}). ")
          else
            "#{char}.#{part}"
          end
        end.join("\n"))
      end
      
      text.gsub!( BACKTICK_CODE_RE ) do |m|
          before,lang,code,after = $~[1..4]
          lang = " lang=\"#{ lang }\"" if lang
          rip_offtags( "#{ before }<pre><code#{ lang }>#{ code.gsub(/\\\`\`\`/,'```') }</code></pre>#{ after }" )
      end
    end
    
    def textile_post_process(text)
      post_inline_textile_span(text)
    end
    
    # Parses a Textile table block, building HTML from the result.
    def block_textile_table( text ) 
        text.gsub!( TABLE_RE ) do |matches|

            caption, id, tatts, fullrow = $~[1..4]
            tatts = pba( tatts, 'table' )
            tatts = shelve( tatts ) if tatts
            rows = []

            fullrow.
            split( /\|$/m ).
            delete_if {|row|row.empty?}.
            each do |row|

                ratts, row = pba( $1, 'tr' ), $2 if row =~ /^(#{A}#{C}\. )(.*)/m
                row << " "
                
                cells = []
                row.split( '|' ).each_with_index do |cell, i|
                    next if i == 0
                    
                    ctyp = 'd'
                    ctyp = 'h' if cell =~ /^_/

                    catts = ''
                    catts, cell = pba( $1, 'td' ), $2 if cell =~ /^(_?#{S}#{A}#{C}\. ?)(.*)/

                    catts = shelve( catts ) if catts
                    cells << "\t\t\t<t#{ ctyp }#{ catts }>#{ cell.strip.empty? ? "&nbsp;" : row.split( '|' ).size-1 != i ? cell : cell[0...cell.length-1] }</t#{ ctyp }>"
                end
                ratts = shelve( ratts ) if ratts
                rows << "\t\t<tr#{ ratts }>\n#{ cells.join( "\n" ) }\n\t\t</tr>"
            end
            caption = "\t<p class=\"caption\">#{caption}</p>\n" if caption
            "#{caption}\t<table#{ tatts }>\n#{ rows.join( "\n" ) }\n\t</table>\n\n"
        end
    end

    # Parses Textile lists and generates HTML
    def block_textile_lists( text )
        orig_text = text.dup
        
        # Take care of _*'s and _#'s to turn them into paragraphs
        text.gsub!(/([\*#] )((.*?\n\s*_[\*#].*?)+)/) do |m|
          "#{$1}<p>"+$2.split(/_[\*#]/).map{|w|w.strip}.delete_if{|w|w.empty?}.join("</p><p>")+"</p>"
        end
        
        @last_line ||= -1
        
        text.gsub!( LISTS_RE ) do |match|
            if text =~ /^#([_0-9]+).*/m
              if $1 == $1.to_i.to_s # then it is a number, so use it
                @last_line = $1.to_i - 2
              end
            else
              @last_line = -1
            end
            lines = match.split( /\n/ )
            depth = []
            lines.each_with_index do |line, line_id|
                if line =~ LISTS_CONTENT_RE 
                  
                    tl,continuation,atts,content = $~[1..4]
                    @last_line += 1 if tl.length == 1
                    
                    unless depth.last.nil?
                        if depth.last.length > tl.length
                            (depth.length - 1).downto(0) do |i|
                                break if depth[i].length == tl.length
                                lines[line_id - 1] << "</li>\n#{"\t"*(depth.size-1)}</#{ lT( depth[i] ) }l>"
                                depth.pop
                                tab_in = true
                            end
                        end
                        if depth.last && depth.last.length == tl.length
                            lines[line_id - 1] << "</li>"
                        end
                    end
                    unless depth.last == tl
                        depth << tl
                        atts = pba( atts )
                        atts << " start=\"#{@last_line + 1}\"" if lT(tl) == "o" && !continuation.empty? && @last_line > 0
                        atts = shelve( atts ) if atts
                        lines[line_id] = "#{"\t"*(depth.size-1)}<#{ lT(tl) }l#{ atts }>\n#{"\t"*depth.size}<li>#{ content }"
                    else
                        lines[line_id] = "#{"\t"*depth.size}<li>#{ content }"
                    end
                elsif line =~ /^([_]+)(#{A}#{C}) (.*)$/m
                    @last_line += 1
                    tl = "u"
                    atts,content = $~[2..3]
                  
                    unless depth.last.nil?
                        if depth.last.length > tl.length
                            (depth.length - 1).downto(0) do |i|
                                break if depth[i].length == tl.length
                                lines[line_id - 1] << "</li>\n#{"\t"*(depth.size-1)}</#{ lT( depth[i] ) }l>"
                                depth.pop
                                tab_in = true
                            end
                        end
                        if depth.last and depth.last.length == tl.length
                            lines[line_id - 1] << "</li>"
                        end
                    end
                    unless depth.last == tl
                        depth << tl
                        atts = pba( atts )
                        atts = shelve( "#{atts} style=\"list-style-type:none;\"" )
                        lines[line_id] = "#{"\t"*(depth.size-1)}<#{ lT(tl) }l#{ atts }>\n#{"\t"*depth.size}<li>#{ content }"
                    else
                        lines[line_id] = "#{"\t"*depth.size}<li>#{ content }"
                    end
                end
                
                if line_id == lines.length - 1
                    tabs = depth.size-1
                    depth.reverse.delete_if do |v|
                        lines[-1] << "</li>\n#{"\t"*tabs}</#{ lT( v ) }l>"
                        tabs -= 1
                    end
                end
            end
            lines.join( "\n" )
        end
        
        text != orig_text
    end

    # Parses Textile definition lists and generates HTML
    def block_textile_defs( text )
        text.gsub!(/^-\s+(.*?):=(.*?)=:\s*$/m) do |m|
          "- #{$1.strip} := <p>"+$2.split(/\n/).map{|w|w.strip}.delete_if{|w|w.empty?}.join("</p><p>")+"</p>"
        end
        
        text.gsub!( DEFS_RE ) do |match|
            lines = match.split( /\n/ )
            lines.each_with_index do |line, line_id|
                if line =~ DEFS_CONTENT_RE 
                    dl,continuation,dt,dd = $~[1..4]
                    
                    atts = pba( atts )
                    atts = shelve( atts ) if atts
                    lines[line_id] = line_id == 0 ? "<dl#{ atts }>" : ""
                    lines[line_id] << "\n\t<dt>#{ dt.strip }</dt>\n\t<dd>#{ dd.strip }</dd>"
                end

                if line_id == lines.length - 1
                    lines[-1] << "\n</dl>"
                end
            end
            lines.join( "\n" )
        end
    end
    
    def inline_textile_code( text ) 
        text.gsub!( CODE_RE ) do |m|
            before,lang,code,after = $~[1..4]
            lang = " lang=\"#{ lang }\"" if lang
            rip_offtags( "#{ before }<code#{ lang }>#{ code.gsub(/\\@(@?)/,'@\1') }</code>#{ after }" )
        end
    end

    def textile_bq( tag, atts, cite, content )
        cite, cite_title = check_refs( cite )
        cite = " cite=\"#{ cite }\"" if cite
        atts = shelve( atts ) if atts
        "\t<blockquote#{ cite }>\n\t\t<p#{ atts }>#{ content }</p>\n\t</blockquote>"
    end

    def textile_p( tag, atts, cite, content )
        atts = shelve( atts ) if atts
        "\t<#{ tag }#{ atts }>#{ content }</#{ tag }>"
    end

    alias textile_h1 textile_p
    alias textile_h2 textile_p
    alias textile_h3 textile_p
    alias textile_h4 textile_p
    alias textile_h5 textile_p
    alias textile_h6 textile_p
    
    def textile_fn_( tag, num, atts, cite, content )
        atts << " id=\"fn#{ num }\""
        content = "<sup>#{ num }</sup> #{ content }"
        atts = shelve( atts ) if atts
        "\t<p#{ atts }>#{ content }</p>"
    end
    
    def textile_ch( tag, atts, cite, content )
      textile_p("h1", atts, cite, content)
    end

    def block_textile_prefix( text ) 
        if text =~ BLOCK_RE
            tag,tagpre,num,atts,cite,content = $~[1..6]
            atts = pba( atts )

            # pass to prefix handler
            if respond_to? "textile_#{ tag }", true
                text.gsub!( $&, method( "textile_#{ tag }" ).call( tag, atts, cite, content ) )
            elsif respond_to? "textile_#{ tagpre }_", true
                text.gsub!( $&, method( "textile_#{ tagpre }_" ).call( tagpre, num, atts, cite, content ) )
            end
        end
    end

    def inline_textile_span( text ) 
        QTAGS.each do |qtag_rc, ht, qtag_re, rtype, escaped_re|
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
            
    def post_inline_textile_span( text ) 
        QTAGS.each do |qtag_rc, ht, qtag_re, rtype, escaped_re|
            text.gsub!( escaped_re ) do |m|
             
                case rtype
                when :limit
                    sta,qtag,atts,cite,content = $~[1..5]
                else
                    qtag,atts,cite,content = $~[1..4]
                    sta = ''
                end
                atts = pba( atts )
                atts << " cite=\"#{ cite }\"" if cite

                "#{ sta }<#{ ht }#{ atts }>#{ content }</#{ ht }>"
            end
        end
    end

    def inline_textile_link( text ) 
        text.gsub!( LINK_RE ) do |m|
            pre,atts,text,title,url,slash,post = $~[1..7]

            url, url_title = check_refs( url )
            title ||= url_title
            
            atts = pba( atts )
            atts = " href=\"#{ url }#{ slash }\"#{ atts }"
            atts << " title=\"#{ title }\"" if title
            atts = shelve( atts ) if atts
            
            "#{ pre }<a#{ atts }>#{ text }</a>#{ post }"
        end
    end

    TEXTILE_REFS_RE =  /(^ *)\[([^\n\[]+?)\](#{HYPERLINK})(?=\s|$)/

    def refs_textile( text ) 
        text.gsub!( TEXTILE_REFS_RE ) do |m|
            flag, url = $~[2..3]
            @urlrefs[flag.downcase] = [url, nil]
            nil
        end
    end

    def inline_textile_image( text ) 
        text.gsub!( IMAGE_RE )  do |m|
            stln,algn,atts,url,title,href,href_a1,href_a2 = $~[1..8]
            atts = pba( atts )
            atts = " src=\"#{ url }\"#{ atts }"
            atts << " title=\"#{ title }\"" if title
            atts << " alt=\"#{ title }\"" 
            # size = @getimagesize($url);
            # if($size) $atts.= " $size[3]";

            href, alt_title = check_refs( href ) if href
            url, url_title = check_refs( url )

            out = ''
            out << "<a#{ shelve( " href=\"#{ href }\"" ) }>" if href
            out << "<img#{ shelve( atts ) } />"
            out << "</a>#{ href_a1 }#{ href_a2 }" if href
            
            if algn 
                algn = h_align( algn )
                if stln == "<p>"
                    out = "<p style=\"float:#{ algn }\">#{ out }"
                else
                    out = "#{ stln }<div style=\"float:#{ algn }\">#{ out }</div>"
                end
            else
                out = stln + out
            end

            out
        end
    end

    def no_textile( text )
        text.gsub!( /(^|\s)(\\?)==([^=]+.*?)\2==(\s|$)?/ ) do |m|
          $2.empty? ? "#{$1}<notextile>#{$3}</notextile>#{$4}" : "#{$1}==#{$3}==#{$4}"
        end
        text.gsub!( /^ *(\\?)==([^=]+.*?)\1==/m ) do |m|
          $1.empty? ? "<notextile>#{$2}</notextile>" : "==#{$2}=="
        end
    end

    def glyphs_textile( text, level = 0 )
        if text !~ HASTAG_MATCH
            pgl text
            footnote_ref text
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
                    glyphs_textile( line, level + 1 )
                else
                    htmlesc( line, :NoQuotes )
                end
                ## p [level, codepre, orig_line, line]

                line
            end
        end
    end

    def textile_popup_help( name, windowW, windowH )
        ' <a target="_blank" href="http://hobix.com/textile/#' + helpvar + '" onclick="window.open(this.href, \'popupwindow\', \'width=' + windowW + ',height=' + windowH + ',scrollbars,resizable\'); return false;">' + name + '</a><br />'
    end
    
    # Turns all urls into clickable links.
    # Taken from ActionPack's ActionView
    def inline_textile_autolink_urls(text)
      text.gsub!(AUTO_LINK_RE) do
        all, a, b, c, d = $&, $1, $2, $3, $5
        if a =~ /<a\s/i # don't replace URL's that are already linked
          all
        else
          %(#{a}<a href="#{b=="www."?"http://www.":b}#{c}">#{b}#{c}</a>#{d})
        end
      end
    end

    # Turns all email addresses into clickable links.
    def inline_textile_autolink_emails(text)
      text.gsub!(/([\w\.!#\$%\-+.]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)+)/, '<a href="mailto:\1">\1</a>')
    end
end

