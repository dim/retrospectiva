require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the packr plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the packr plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Packr'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

spec = Gem::Specification.new do |spec| 
  spec.name = "packr"
  spec.version = "1.0.2"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "A Ruby port of Dean Edwards' JavaScript compressor"
  spec.require_path = "lib"
  spec.files = FileList["lib/**/*"].to_a
  spec.autorequire = "lib/packr.rb"
  spec.author = "James Coglan"
  spec.email = "james@jcoglan.com"
  spec.homepage = "http://blog.jcoglan.com/packr/"
  spec.test_files = FileList["test/**/*"].to_a
  spec.has_rdoc = true
  spec.extra_rdoc_files = ["README"]
  spec.rdoc_options << "--main" << "README" << '--line-numbers' << '--inline-source'
end
 
Rake::GemPackageTask.new(spec) do |pkg| 
  pkg.need_tar = true 
end
