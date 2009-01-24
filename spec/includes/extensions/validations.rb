module Spec
  module Rails
    module Matchers
      def validate_inclusion_of(attribute, options = {})
        return simple_matcher("model to validate inclusion of #{attribute} in #{options[:in].inspect}") do |model|
          model.send("#{attribute}=", '$$_asdf_$$')
          !model.valid? && model.errors.invalid?(attribute)
        end
      end

      def validate_numericality_of(attribute, options = {})
        return simple_matcher("model to validate numericality of #{attribute} with #{options.inspect}") do |model|
          steps = []
          model.send "#{attribute}=", 'SOME STRING'
          steps << !model.valid? && model.errors.invalid?(attribute)
          if options[:min]
            model.send "#{attribute}=", options[:min] - 1
            steps << !model.valid? && model.errors.invalid?(attribute)
          end
          if options[:max]
            model.send "#{attribute}=", options[:max] + 1
            steps << !model.valid? && model.errors.invalid?(attribute)
          end
          unless options[:nil]
            model.send "#{attribute}=", nil
            steps << !model.valid? && model.errors.invalid?(attribute)
          end
          !steps.include?(false)
        end
      end      
    end
  end
end