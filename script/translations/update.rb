#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../config/environment'

#Dir[RAILS_ROOT + '/locales/app.*.yml'].each do |file|
#  RetroI18n.update(file, RAILS_ROOT + '/app/', RAILS_ROOT + '/lib/')
#end  

module RetroI18n
  
  class SettingsFile < LocaleFile   

    class SettingsHash < ActiveSupport::OrderedHash
    
      def to_yaml( opts = {} )
        fake = Hash.new
        YAML::quick_emit( fake.object_id, opts ) do |out|          
          out.map( fake.taguri, fake.to_yaml_style ) do |map|
            each do |k, v|
              map.add( k, v )
            end
          end
        end
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
      hash = { locale => { 'settings' => updated_translations } }
      File.open(path, 'w+') do |file|
        file << hash.to_yaml.gsub(/\A[-]+ *\n/m, '')
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


I18n.backend.send :init_translations

Dir[RAILS_ROOT + '/locales/settings.*.yml'].each do |file|
  settings = RetroI18n::SettingsFile.new(file)
  next if settings.locale == 'en-US'
  settings.update

end  


