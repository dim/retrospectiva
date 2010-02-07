module ActionView::Helpers::TextHelper
    
  def auto_link_urls(text, html_options = {})
    link_attributes = html_options.stringify_keys
    text.gsub(AUTO_LINK_RE) do
      href = $&
      punctuation = ''
      left, right = $`, $'
      
      
      # detect already linked URLs and URLs in the middle of a tag
      if left =~ /<[^>]+$/ && right =~ /^[^>]*>/
        # do not change string; URL is alreay linked
        href
      else
        # ADDED - START
        href.sub!(/&amp;/, '&')
        if href.sub!(/&(quot|lt|gt);.*$/, '')
          punctuation = $&
        end
        # ADDED - END

        # don't include trailing punctuation character as part of the URL
        if href.sub!(/[^\w\/-]$/, '') and punctuation = $& and opening = BRACKETS[punctuation]
          if href.scan(opening).size > href.scan(punctuation).size
            href << punctuation
            punctuation = ''
          end
        end

        link_text = block_given?? yield(href) : href
        href = 'http://' + href unless href.index('http') == 0

        content_tag(:a, escape_once(link_text), link_attributes.merge('href' => href)) + punctuation
      end
    end
  end

end
