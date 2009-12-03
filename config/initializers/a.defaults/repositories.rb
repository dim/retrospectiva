# Load GIT libraries
SCM_GIT_ENABLED = begin
  system("#{TinyGit.git_binary} --version 1> /dev/null 2> /dev/null")
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
rescue LoadError, Exception => e
  false
end unless Object.const_defined?(:SCM_SUBVERSION_ENABLED) && Object.const_get(:SCM_SUBVERSION_ENABLED) == false
