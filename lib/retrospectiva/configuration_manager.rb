require 'retrospectiva/configuration_manager/exceptions'
require 'retrospectiva/configuration_manager/configuration'
require 'retrospectiva/configuration_manager/units'
require 'retrospectiva/configuration_manager/core_ext'

module Retrospectiva
  module ConfigurationManager  
    extend self

    def [](name)
      object = find(name)
      raise InvalidSectionError, "Invalid section: '#{name}'" unless object.is_a?(Section)
      object
    end

    def sections
      @sections ||= load_sections
    end
    
    def update(section_hash)
      configuration.section_hash = section_hash
      configuration.save
    end
    
    def save!
      configuration.save
    end    
    
    def reload!
      @updated_at = configuration.updated_at
      configuration.apply(false)
    end

    def find(name)
      sections.find {|i| i.name == name.to_s }
    end
    
    def synchronize
      configuration.reload 
      reload_required? && reload!      
    end

    def configuration
      @configuration ||= Configuration.find_or_create
    end

    protected
            
      def updated_at
        @updated_at
      end
      
      def reload_required?
        updated_at.nil? || updated_at < configuration.updated_at
      end

    private
      
      # Loads the array of sections      
      def load_sections
        settings_file = File.join(RAILS_ROOT, 'app', 'core_settings.yml')
        result = YAML.load_configuration(settings_file, [])
        merge_extensions!(result)
        result.each(&:validate_and_link!)
        result
      end
  
      def merge_extensions!(core_settings)
        raise 'RetroEM is not loaded (must be loaded before RetroCM)' unless RetroEM.loaded?
        
        RetroEM.installed_extensions.each do |extension|
          next unless File.exists?(extension.settings_path)
          
          YAML.load_configuration(extension.settings_path, []).each do |setting|
            existing = core_settings.find {|i| i.name == setting.name }
            existing ? existing.merge!(setting) : core_settings.push(setting)
          end
        end
      end
          
  end  
end  

RetroCM = Retrospectiva::ConfigurationManager
ActionController::Base.class_eval do
  prepend_before_filter :synchronise_retro_cm

  private
    def synchronise_retro_cm
      RetroCM.synchronize || true
    end
end unless RAILS_ENV == 'test'
