require(File.join(File.dirname(__FILE__), '..', '..', 'config', 'boot'))

require 'rake'
require 'spec/rake/spectask'

desc 'Default: run unit tests.'
task :default => :spec

desc "Run the extension specs"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
  t.spec_files = FileList["spec/**/*_spec.rb"]
end
