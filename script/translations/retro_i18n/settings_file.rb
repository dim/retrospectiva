module RetroI18n  
  class SettingsFile < LocaleFile   

    class SettingsHash < ActiveSupport::OrderedHash
    
      def ya2yaml( emitter, level = 1 )
        prefix = " " * (2 * (level - 1))
        map do |key, value|        
          text = case value
          when SettingsHash
            value.ya2yaml( emitter, level + 1 )
          when String
            emitter.emit_string(value.strip, level)
          else
            nil
          end
          "\n#{prefix}#{emitter.emit_string(key, level)}: #{text}"
        end.join
      end 
      
    end

    def updated_translations
      RetroCM.sections.inject(SettingsHash.new) do |result, section|          
        merge_unit! result, section                              
        
        section.groups.each do |group|
          result[section.name]['groups'] ||= SettingsHash.new
          merge_unit! result[section.name]['groups'], group

          group.settings.each do |setting|
            result[section.name]['groups'][group.name]['settings'] ||= SettingsHash.new
            merge_unit! result[section.name]['groups'][group.name]['settings'], setting                               
          end
        end
        
        result
      end  
    end      

    def save
      yaml    = Ya2YAML.new :syck_compatible => true
      content = updated_translations.ya2yaml(yaml, 3)
      
      File.open(path, 'w+') do |file|
        file << "#{locale}:\n  settings:"
        file << content 
      end
    end
    alias_method :update, :save

    protected
      
      def merge_unit!(result, unit)        
        tokens = unit.translation_scope[1..-1].map(&:to_s)
        label = t(tokens + [unit.name, 'label'])
        description = t(tokens + [unit.name, 'description'])
                        
        result[unit.name] ||= SettingsHash.new
        result[unit.name]['label'] = label
        result[unit.name]['description'] = description if description.present?
      end
      
      def load_translations
        (YAML.load_file(path)[locale]['settings'] || {}) rescue {}
      end
    
      def t(tokens)
        tokens.inject(translations) do |result, key|
          result[key]
        end
      rescue
        nil
      end
    
  end
end
