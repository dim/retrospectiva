require 'spec'
require File.dirname(__FILE__) + '/../lib/tiny_git'

unless Object.const_defined?(:TEST_REP_PATH)
  TEST_REP_PATH = File.join(File.dirname(__FILE__), 'test_rep')
end

unless File.directory?(TEST_REP_PATH)
  `/usr/bin/env tar xv -f #{File.dirname(__FILE__)}/test_rep.tgz -C #{File.dirname(__FILE__)}`
  sleep(1)
end

unless Object.const_defined?(:TEST_REP)
  TEST_REP = TinyGit::Repo.new(File.join(File.dirname(__FILE__), 'test_rep'))
end

def create_test_repo
end

def drop_test_repo
end