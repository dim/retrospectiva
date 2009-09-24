
# Add the directory containing this file to the start of the load path if it
# isn't there already.
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'active_support'
require 'tiny_git/commands'
require 'tiny_git/repo'
require 'tiny_git/object'
require 'tiny_git/change'
require 'tiny_git/author'
require 'tiny_git/caching'

module TinyGit
  mattr_accessor :git_binary
  self.git_binary = "/usr/bin/env git"
end
