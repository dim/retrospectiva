module FormatHelper

  def markup_with_wiki_words(text, options = {})
    text.gsub!(WikiEngine.link_pattern) do |match|
      match.gsub(/\|/, ':')
    end
    markup_without_wiki_words(text, options)
  end
  alias_method_chain :markup, :wiki_words

  def path_to_wiki_file(file)
    file.format? ? formatted_project_wiki_file_path(Project.current, file, file.format) : project_wiki_file_path(Project.current, file)
  end
  
  protected
  
    def format_internal_links_with_wiki_words(markup, options = {})
      reference_wiki_words(format_internal_links_without_wiki_words(markup, options), options)
    end
    alias_method_chain :format_internal_links, :wiki_words

  private
  
    def reference_wiki_words(markup, options = {})
      return markup if Project.current.blank? and not options[:demo]

      WikiEngine.link_all(markup) do |match, prefix, page, title|
        if page.to_s.size < 2
          match
        elsif options[:demo] and prefix != 'I'         
          link_to_function h(title)
        elsif options[:demo] and prefix == 'I'         
          image_tag('http://retrospectiva.org/images/logo_small.png', :alt => h(title))
        elsif User.current.permitted?(:wiki_pages, :view) and prefix == 'F'
          file = Project.current.wiki_files.find_readable(page)
          file ? link_to(h(title), path_to_wiki_file(file), :class => 'download', :title => h(file.file_name)) : h(title) 
        elsif User.current.permitted?(:wiki_pages, :view) and prefix == 'I'
          file = Project.current.wiki_files.find_readable_image(page)
          file ? image_tag(path_to_wiki_file(file), :alt => h(title)) : h(title) 
        elsif User.current.permitted?(:wiki_pages, :view) and Project.current.existing_wiki_page_titles.map(&:downcase).include?(page.downcase)
          link_to h(title), project_wiki_page_path(Project.current, page)
        elsif User.current.permitted?(:wiki_pages, :update)
          link = link_to h('?'), edit_project_wiki_page_path(Project.current, page)
          "<span class=\"highlight\">#{h(title)}#{link}</span>"        
        else
          h(title)
        end
      end
    end  

end
