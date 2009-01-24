module Retrospectiva
  module ConfigurationManager

    class AbstractUnit
      attr_accessor :name
  
      def records
        raise 'Abstract Method'
      end
  
      def validate_and_link!
        missing_attributes = []
        missing_attributes << :name if name.blank?
        missing_attributes << :label if label.blank?
        unless missing_attributes.empty?
          raise InvalidDefinitionError, "Invalid definition: #{inspect}. Missing attributes: #{missing_attributes.join(', ')}" 
        end
      end

      def keys
        records.map(&:name)
      end
      
      def find(name)
        records.find {|i| i.name == name.to_s }          
      end
      
      def merge!(other)
        other.records.each do |record|
          existing = find(record.name)
          existing ? existing.merge!(record) : records.push(record)
        end
      end
      
      def translation_scope
        [:settings]
      end
            
      def label(options = {})
        I18n.t "#{name}.label", options.merge(:scope => translation_scope).reverse_merge(:default => default_label)
      end

      def default_label
        I18n.t "#{name}.label", :scope => translation_scope, :locale => I18n.default_locale, :default => ''
      end

      def description(options = {})
        I18n.t "#{name}.description", options.merge(:scope => translation_scope).reverse_merge(:default => '')
      end
      
    end  
      
    class Section < AbstractUnit
      attr_accessor :groups
  
      def [](name)
        object = find(name)
        raise InvalidGroupError, "Invalid group: '#{name}'" unless object.is_a?(Group)
        object
      end

      def records
        groups
      end

      def inspect
        "<#{self.class.name} groups: #{keys.inspect}>"
      end

      def validate_and_link!
        super
        groups.each do |group|
          group.section = self
          group.validate_and_link!
        end      
      end
    end


    class Group < AbstractUnit
      attr_accessor :settings, :section
  
      def [](setting)
        setting(setting).value
      end
  
      def []=(setting, value)
        setting(setting).value = value
      end

      def setting(name)
        object = find(name)
        raise InvalidSettingError, "Invalid setting: '#{name}'" unless object.is_a?(AbstractSetting)
        object
      end

      def records
        settings
      end

      def inspect
        "<#{self.class} settings: #{keys.inspect}>"
      end
      
      def validate_and_link!
        super
        self.settings.each do |setting|
          setting.group = self
          setting.validate_and_link!
        end      
      end

      def translation_scope
        [:settings, section.name.to_sym, :groups]
      end

    end

    
    class AbstractSetting < AbstractUnit
      attr_accessor :allow_blank, :default, :group, :after_change
      
      def path
        "#{group.section.label} / #{group.label} / #{name.humanize}"
      end
      
      def default?
        default == value
      end
      
      def value
        @value = default if @value.nil?
        @value.dup rescue @value
      end  

      def value=(new_value)
        old_value = @value
        begin
          @value = new_value
          validate_and_link!
          eval(after_change) if after_change
        rescue
          @value = old_value
          raise $!
        end
        @value
      end  
  
      def to_s
        value
      end
  
      def validate_and_link!  
        super
        if allow_blank != true && value.blank?
          raise InvalidSettingDefinitionError, "Setting #{path} cannot have a blank value"
        end
      end

      def merge!(other)
        (other.instance_variables - ['@name']).each do |var|
          var.gsub!(/@/, '')
          case val = other.send(var)
          when Array then send("#{var}=", send(var) | val)
          when nil   then next
          else            send("#{var}=", val)
          end
        end
      end        

      def translation_scope
        [:settings, group.section.name.to_sym, :groups, group.name.to_sym, :settings]
      end

    end

  
    class StringSetting < AbstractSetting
      attr_accessor :format
      
      def validate_and_link!  
        if !format.blank? && !format.is_a?(Regexp)
          raise InvalidSettingDefinitionError, "Setting's #{path} 'format' must be a regular expression"
        end
        
        if !format.blank? && !value.blank? && !value.match(format)
          raise InvalidValueError, 'Setting has an invalid format'
        end
        @value = nil if @value.blank?
        
        super
      end
    end

    class PasswordSetting < StringSetting
    end

    class TextSetting < StringSetting
    end

    class IntegerSetting < AbstractSetting
      attr_accessor :min, :max

      def validate_and_link!  
        begin
          @value = Kernel.Integer(value.to_s)
        rescue ArgumentError, TypeError
          raise InvalidValueError, "Tried to assign a non-numeric value: '#{value}'."
        end
        if min && @value < min
          raise InvalidSettingDefinitionError, "Setting #{path} has a minimum value of #{min}"
        elsif max && @value > max
          raise InvalidSettingDefinitionError, "Setting #{path} has a maximum value of #{max}"
        end
        super
      end
    end

    class BooleanSetting < AbstractSetting
      def value=(new_value)
        new_value = (new_value == '1' ? true : (new_value == '0' ? false : new_value))
        super(new_value)
      end  

      def validate_and_link!  
        if allow_blank != true && value.nil?
          raise InvalidSettingDefinitionError, "Setting #{path} cannot have a blank value"
        end
        unless [true, false].include?(value)
          raise InvalidValueError, "Tried to assign an invalid value '#{value}'. Valid values are either 'true' or 'false'"
        end
      end
    end
  
    class SelectSetting < AbstractSetting
      attr_accessor :options, :evaluate
      
      def values
        self.options.map do |option|
          option.is_a?(Array) ? option.last.to_s : option.to_s
        end
      end

      def validate_and_link!  
        super
        
        if options.blank? && evaluate
          self.options = eval(evaluate)
        end
                  
        if self.options.blank?
          raise InvalidSettingDefinitionError, "Setting #{path} has no options defined"
        end

        unless self.values.include?(value.to_s)
          raise InvalidValueError, "Tried to assign an invalid value '#{value}'. Valid values are: [#{values.join(', ')}]"
        end
      end
    end


  end
end
