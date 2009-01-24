module MarkupHelper

  def main_navigation
    @examples.map do |section, strings|
      next if strings.blank?
      "<li>#{link_to h(section), :anchor => section.to_s.to_web_safe_name}</li>"
    end.join
  end
  
  protected 
    
    def format_internal_links(markup, options = {})
      super(markup, options.merge(:demo => true))
    end

end
