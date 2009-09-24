module TinyGit  
  class GitTagNameDoesNotExist < StandardError 
  end
  module Object    
  end
end
require 'tiny_git/object/abstract'
require 'tiny_git/object/blob'
require 'tiny_git/object/commit'
require 'tiny_git/object/tree'