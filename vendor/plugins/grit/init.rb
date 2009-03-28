require 'grit'
Grit.logger = RAILS_DEFAULT_LOGGER if Object.const_defined?(:RAILS_DEFAULT_LOGGER)