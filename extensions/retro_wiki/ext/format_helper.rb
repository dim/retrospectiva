module FormatHelper

  def markup_with_wiki_words(text, options = {})
    text.gsub!(WikiEngine.wiki_word_pattern) do |match|
      match.gsub(/\|/, ':')
    end
    markup_without_wiki_words(text, options)
  end
  alias_method_chain :markup, :wiki_words

  def path_to_wiki_file(file)
    file.format? ? project_wiki_file_path(Project.current, file, :format => file.format) : project_wiki_file_path(Project.current, file)
  end
  
  protected

    def internal_link_pattern_with_wiki_words
      /(?:#{internal_link_pattern_without_wiki_words})|(?:#{WikiEngine.wiki_word_pattern})/
    end
    alias_method_chain :internal_link_pattern, :wiki_words

    def format_internal_link_with_wiki_words(match_data, options)
      if match_data[0] =~ WikiEngine.wiki_word_pattern
        format_wiki_word_link(match_data, options)
      else
        format_internal_link_without_wiki_words(match_data, options)
      end
    end
    alias_method_chain :format_internal_link, :wiki_words

    def format_wiki_word_link(match_data, options)
      WikiEngine.parse_wiki_word_link(match_data) do |prefix, page, title, size|

        if page.to_s.size < 2
          match_data[0]
        elsif page.to_s == 'BR'
          '<br />'
        elsif options[:demo] and prefix != 'I'         
          link_to_function h(title)
        elsif options[:demo] and prefix == 'I'
          image_tag('http://retrospectiva.org/images/logo_small.png', :alt => h(title), :size => size)
        elsif permitted?(:wiki_pages, :view) and prefix == 'F'
          file = Project.current.wiki_files.find_readable(page)
          file ? link_to(h(title), path_to_wiki_file(file), :class => 'download', :title => h(file.file_name)) : h(title) 
        elsif permitted?(:wiki_pages, :view) and prefix == 'I'
          file = Project.current.wiki_files.find_readable_image(page)
          file ? image_tag(path_to_wiki_file(file), :alt => h(title), :size => size) : h(title) 
        elsif permitted?(:wiki_pages, :view) and Project.current.existing_wiki_page_titles.map(&:downcase).include?(page.downcase)
          link_to h(title), project_wiki_page_path(Project.current, page)
        elsif permitted?(:wiki_pages, :update)
          link = link_to h('?'), edit_project_wiki_page_path(Project.current, page)
          "<span class=\"highlight\">#{h(title)}#{link}</span>"        
        else
          h(title)
        end        
      
      end
    end

end
