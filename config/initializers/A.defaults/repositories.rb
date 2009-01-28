# Load GIT libraries
SCM_GIT_ENABLED = begin
  require 'grit'
  require 'grit/git'

  Grit::Tree.class_eval do
    def acts_like_node?; true; end
  end

  Grit::Blob.class_eval do
    def acts_like_node?; true; end
  end

  true
rescue LoadError
  false
end unless Object.const_defined?(:SCM_GIT_ENABLED) && Object.const_get(:SCM_GIT_ENABLED) == false

# Load subversion binding libraries
SCM_SUBVERSION_ENABLED = begin
  require 'svn/core'
  require 'svn/fs'
  require 'svn/delta'
  require 'svn/info'
  require 'svn/repos'
  require 'svn/client'
  true
rescue LoadError
  false
end unless Object.const_defined?(:SCM_SUBVERSION_ENABLED) && Object.const_get(:SCM_SUBVERSION_ENABLED) == false
