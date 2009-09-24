module TinyGit  
  class GitExecuteError < StandardError 
  end

  class Repo    
    include Commands

    attr_reader :git_dir

    def initialize(path, logger = nil)
      @git_dir = if File.exist?(File.join(path, '.git', 'HEAD'))
        File.join(path, '.git')
      else
        path
      end
      @logger = logger      
    end

    def commit(sha)
      TinyGit::Object::Commit.new(self, sha)
    end

    def blob(sha)
      TinyGit::Object::Blob.new(self, sha)
    end

  end  
end
