require 'retrospectiva/core_ext'
require 'retrospectiva/extension_manager/extension_installer'

Retrospectiva::ExtensionManager::ExtensionInstaller.installed_extension_names.each do |name|
  Dir["#{RAILS_ROOT}/extensions/#{name}/**/*.rake"].sort.each { |ext| load ext }
end