WillPaginate::Finder::ClassMethods.class_eval do
  
  protected
  
    def wp_parse_options_with_per_page_limitation(*args) #:nodoc:
      page, per_page, total = wp_parse_options_without_per_page_limitation(*args)
      per_page = self.per_page if per_page.to_i < 1 || per_page.to_i > 100
      [page, per_page, total]
    end
    alias_method_chain :wp_parse_options, :per_page_limitation
  
end
