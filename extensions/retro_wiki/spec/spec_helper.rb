ENV['RETRO_EXT'] ||= 'retro_wiki'
require File.expand_path(File.dirname(__FILE__) + '/../../../spec/spec_helper')

Spec::Runner.configure do |config|
  config.fixture_path = File.dirname(__FILE__) + '/fixtures/'
end
