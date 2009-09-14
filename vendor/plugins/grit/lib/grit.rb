$:.unshift File.dirname(__FILE__) # For use/testing when no gem is installed

# core
require 'fileutils'
require 'time'

# stdlib
require 'timeout'
require 'logger'
require 'digest/sha1'

if defined? RUBY_ENGINE && RUBY_ENGINE == 'jruby'
  require 'open3'
else
  require 'open3_detach'
end

# third party
begin
  require 'mime/types'
rescue LoadError
  require 'rubygems'
  gem "mime-types", ">=0"
  require 'mime/types'  
end

# ruby 1.9 compatibility
require 'grit/ruby1.9'

# internal requires
require 'grit/lazy'
require 'grit/errors'
require 'grit/git'
require 'grit/caching'
require 'grit/ref'
require 'grit/tag'
require 'grit/commit'
require 'grit/commit_stats'
require 'grit/tree'
require 'grit/blob'
require 'grit/actor'
require 'grit/diff'
require 'grit/config'
require 'grit/repo'
require 'grit/index'
require 'grit/status'
require 'grit/submodule'
require 'grit/blame'
require 'grit/merge'


module Grit
  class << self

    # Set +debug+ to true to log all git calls and responses
    attr_accessor :debug

    # The standard +logger+ for debugging git calls - this defaults to a plain STDOUT logger
    attr_accessor :logger
    
  end
  
  self.debug = false
  self.logger ||= ::Logger.new(STDOUT)

  def self.version
    yml = YAML.load(File.read(File.join(File.dirname(__FILE__), *%w[.. VERSION.yml])))
    "#{yml[:major]}.#{yml[:minor]}.#{yml[:patch]}"
  end
  
end
