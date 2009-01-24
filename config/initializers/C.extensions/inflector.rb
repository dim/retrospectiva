#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
ActiveSupport::Inflector.module_eval do
  def web_safe_name(string)
    string.dup.downcase.
      gsub(/['"]/, '').      # replace quotes by nothing
      gsub(/\W/, ' ').       # strip all non word chars
      gsub(/\ +/, '-').      # replace all white space sections with a dash
      gsub(/-{2,}/, '-').    # trim multiple dashes
      gsub(/(-)$/, '').      # trim dashes
      gsub(/^(-)/, '')        
  end  
end

String.class_eval do
  def to_web_safe_name
    ActiveSupport::Inflector.web_safe_name(self)
  end
end