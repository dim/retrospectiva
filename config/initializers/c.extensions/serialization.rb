ActiveRecord::Base.class_eval do
  
  def to_xml_with_defaults(options = {}, &block)    
    options[:only]    = serialize_only      if respond_to?(:serialize_only) 
    options[:except]  = serialize_except    if respond_to?(:serialize_except) 
    options[:methods] = serialize_methods   if respond_to?(:serialize_methods) 
    options[:include] = serialize_including if respond_to?(:serialize_including)

    options[:overwrite].each do |key, values|
      options[key] ||= []
      options[key] = values
    end if options[:overwrite]

    options[:merge].each do |key, values|
      options[key] ||= []
      options[key] += values
    end if options[:merge]
    
    to_xml_without_defaults(options, &block)
  end
  alias_method_chain :to_xml, :defaults
  
end