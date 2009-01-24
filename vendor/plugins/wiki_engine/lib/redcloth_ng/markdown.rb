unless defined? RedCloth
  $:.unshift(File.dirname(__FILE__))
  require 'base'
end

class RedCloth < String

    DEFAULT_RULES << :markdown

    # == Markdown
    #
    # refs_markdown::         Markdown references (for example: [hobix]: http://hobix.com/)
    # block_markdown_setext:: Markdown setext headers
    # block_markdown_atx::    Markdown atx headers
    # block_markdown_rule::   Markdown horizontal rules
    # block_markdown_bq::     Markdown blockquotes
    # block_markdown_lists::  Markdown lists
    # inline_markdown_link::  Markdown links
    #
    
    #######
    private
    #######

    def block_markdown_setext( text )
        if text =~ SETEXT_RE
            tag = if $2 == "="; "h1"; else; "h2"; end
            blk, cont = "<#{ tag }>#{ $1 }</#{ tag }>", $'
            blocks cont
            text.replace( blk + cont )
        end
    end

    def block_markdown_atx( text )
        if text =~ ATX_RE
            tag = "h#{ $1.length }"
            blk, cont = "<#{ tag }>#{ $2 }</#{ tag }>\n\n", $'
            blocks cont
            text.replace( blk + cont )
        end
    end

    MARKDOWN_BQ_RE = /\A(^ *> ?.+$(.+\n)*\n*)+/m

    def block_markdown_bq( text )
        text.gsub!( MARKDOWN_BQ_RE ) do |blk|
            blk.gsub!( /^ *> ?/, '' )
            flush_left blk
            blocks blk
            blk.gsub!( /^(\S)/, "\t\\1" )
            "<blockquote>\n#{ blk }\n</blockquote>\n\n"
        end
    end

    MARKDOWN_RULE_RE = /^(.*)( ?[#{
        ['*', '-', '_'].collect { |ch| Regexp::quote( ch ) }.join
    }] ?){3,}(.*)$/

    def block_markdown_rule( text )
        text.gsub!( MARKDOWN_RULE_RE ) do |blk|
            if $3.empty? && $1 =~ /[#{['*', '-', '_'].collect { |ch| Regexp::quote( ch ) }.join}]*/
                "<hr />"
            else
                blk
            end
        end
    end

    # XXX TODO XXX
    def block_markdown_lists( text )
    end

    def inline_markdown_link( text )
    end

    MARKDOWN_REFLINK_RE = /
            \[([^\[\]]+)\]      # $text
            [ ]?                # opt. space
            (?:\n[ ]*)?         # one optional newline followed by spaces
            \[(.*?)\]           # $id
        /x 

    def inline_markdown_reflink( text ) 
        text.gsub!( MARKDOWN_REFLINK_RE ) do |m|
            text, id = $~[1..2]

            if id.empty?
                url, title = check_refs( text )
            else
                url, title = check_refs( id )
            end
            
            atts = " href=\"#{ url }\""
            atts << " title=\"#{ title }\"" if title
            atts = shelve( atts )
            
            "<a#{ atts }>#{ text }</a>"
        end
    end

    MARKDOWN_LINK_RE = /
            \[([^\[\]]+)\]      # $text
            \(                  # open paren
            [ \t]*              # opt space
            <?(.+?)>?           # $href
            [ \t]*              # opt space
            (?:                 # whole title
            (['"])              # $quote
            (.*?)               # $title
            \3                  # matching quote
            )?                  # title is optional
            \)
        /x 

    def inline_markdown_link( text ) 
        text.gsub!( MARKDOWN_LINK_RE ) do |m|
            text, url, quote, title = $~[1..4]

            atts = " href=\"#{ url }\""
            atts << " title=\"#{ title }\"" if title
            atts = shelve( atts )
            
            "<a#{ atts }>#{ text }</a>"
        end
    end

    MARKDOWN_REFS_RE = /(^ *)\[([^\n]+?)\]:\s+<?(#{HYPERLINK})>?(?:\s+"((?:[^"]|\\")+)")?(?=\s|$)/m

    def refs_markdown( text )
        text.gsub!( MARKDOWN_REFS_RE ) do |m|
            flag, url = $~[2..3]
            title = $~[6]
            @urlrefs[flag.downcase] = [url, title]
            nil
        end
    end
end

