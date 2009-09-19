require 'erb'

YAML.module_eval do
  def self.load_configuration(path, default_value)
    path = "#{path}.default" unless File.exist?(path)
    (YAML.load(ERB.new(File.read(path)).result) rescue default_value) || default_value
  end
end

Hash.class_eval do
  
  def only(*keys)
    dup.only!(*keys)
  end
  
  def only!(*keys)
    keys.map! { |key| convert_key(key) } if respond_to?(:convert_key)
    delete_if { |k,| !keys.include?(k) }
    self
  end
  
end
