ENV["RAILS_ENV"] = "test"

require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'spec'
require 'spec/rails'

Attachment.storage_path = File.join(File.dirname(__FILE__), '..', 'tmp')    

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = File.dirname(__FILE__) + '/fixtures/'
end
