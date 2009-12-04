module Retrospectiva
  module ConfigurationManager
    
    class ConfigurationProxy < OpenStruct
      
      def initialize
        super :section_hash => {}, :updated_at => Time.now, :errors => []
      end
      
      def reload(*args)
        true
      end
      
      def save(*args)
        true
      end

      def apply(*args)
        true
      end

    end
    
    class Configuration < ActiveRecord::Base
      set_table_name 'configuration'
      serialize :section_hash, Hash

      def self.find_or_create
        find(:first) || create(:section_hash => {})
      rescue ActiveRecord::StatementInvalid
        ConfigurationProxy.new
      end        

      def section_hash
        value = read_attribute(:section_hash)
        value.is_a?(Hash) ? value : {}
      end
      
      def each_setting(alternative = nil)        
        (alternative || section_hash).each do |section_name, group_hash|            
          group_hash.each do |group_name, setting_hash|
            setting_hash.each do |setting_name, value|
              yield(section_name, group_name, setting_name, value)
            end
          end  
        end        
      end
      
      def apply(store_errors = true, alternative = nil)
        each_setting(alternative || section_hash) do |section_name, group_name, setting_name, value|
          begin                
            RetroCM[section_name][group_name][setting_name] = value
          rescue Error => e
            if store_errors
              setting = RetroCM[section_name][group_name].setting(setting_name)
              errors.add_to_base "[#{setting.path}] #{e.message}"
            end
          end
        end
        store_errors ? errors.empty? : true
      end
      
      def revert
        apply(false, section_hash_was)
      end
      
      protected
      
        def sanitize_configuration!
          section_hash.delete_if do |section_name, group_hash|
            section = RetroCM.find(section_name)
            group_hash.delete_if do |group_name, setting_hash|
              group = section.find(group_name)
              setting_hash.delete_if do |setting_name, value|
                group.find(setting_name).blank?
              end if group
              group.blank?
            end if section
            section.blank?
          end
        end

        def before_validation
          sanitize_configuration!          
        end
        
        def validate
          apply || ( revert && false )
        end
      
        def before_save
          self.section_hash = RetroCM.sections.inject({}) do |result, section|
            section.groups.each do |group|
              group.settings.each do |setting|
                next if setting.default?
                result[section.name] ||= {}
                result[section.name][group.name] ||= {}
                result[section.name][group.name][setting.name] = setting.value
              end
            end
            result
          end        
        end
      
    end
  
  end
end
    
    
    