ActionController::Base.class_eval do
  
  class << self

    def filter_parameter_logging(*filter_words, &block)
      parameter_filter = Regexp.new(filter_words.collect{ |s| s.to_s }.join('|'), true) if filter_words.length > 0

      define_method(:filter_parameters) do |unfiltered_parameters|
        filtered_parameters = {}

        unfiltered_parameters.each do |key, value|
          if key =~ parameter_filter
            filtered_parameters[key] = '[FILTERED]'
          elsif value.is_a?(Hash)
            filtered_parameters[key] = filter_parameters(value)
          elsif value.is_a?(Array)
            filtered_parameters[key] = value.collect do |item|
              item.is_a?(Hash) ? filter_parameters(item) : item
            end
          elsif block_given?
            key = key.dup
            value = value.dup if value
            yield key, value
            filtered_parameters[key] = value
          else
            filtered_parameters[key] = value
          end
        end

        filtered_parameters
      end
      protected :filter_parameters
    end
  
  end
end
