require 'spec'
require File.dirname(__FILE__) + '/../lib/tiny_git'

unless Object.const_defined?(:TEST_REP)
  TEST_REP = TinyGit::Repo.new(File.join(File.dirname(__FILE__), 'test_rep'))
end