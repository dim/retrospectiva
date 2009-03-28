$: << File.dirname(__FILE__) + '/../mime-types/lib'
$: << File.dirname(__FILE__) + '/lib'

RAILS_ROOT = File.expand_path(File.dirname(__FILE__) + '/../../..')

require 'rubygems'
require 'benchmark'
require File.dirname(__FILE__) + '/init'

Grit.logger.level = Logger::INFO
repo = Grit::Repo.new(RAILS_ROOT)
tree = repo.tree('HEAD')

Benchmark.bm(16) do |x|

  x.report("rev-list(n=1)") do
    100.times { repo.rev_list('HEAD', :n => 1) }
  end
  x.report("rev-list(n=30)") do
    100.times { repo.rev_list('HEAD', 'app/', :n => 30) }
  end
  x.report("log(n=1)")   do
    100.times { repo.log('HEAD', '', :n => 1) }
  end
  x.report("log(n=30)")   do
    100.times { repo.log('HEAD', '', :n => 30) }
  end    
  x.report("commits(n=1)")   do
    100.times { repo.commits('HEAD', 1) }
  end
  x.report("commits(n=30)")   do
    100.times { repo.commits('HEAD', 30) }
  end    
  x.report("tree") do
    100.times { repo.tree('HEAD') }
  end  
  x.report("sub-nodes") do
    100.times { repo.tree('HEAD', ['app/models']).contents }
  end
  x.report("diff") do
    100.times do 
      text = repo.git.run '', 'diff', '', {}, ['076787', '31071b', '--', 'extensions/retro_blog/locales/app/en-GB.yml']
      Grit::Diff.list_from_string(repo, text).first
    end
  end  
end

puts "\n\n"

Grit.cache do
  Benchmark.bm(16) do |x|
    x.report("rev-list(n=1)") do
      100.times { repo.rev_list('HEAD', :n => 1) }
    end
    x.report("rev-list(n=30)") do
      100.times { repo.rev_list('HEAD', 'app/', :n => 30) }
    end
    x.report("log(n=1)")   do
      100.times { repo.log('HEAD', '', :n => 1) }
    end
    x.report("log(n=30)")   do
      100.times { repo.log('HEAD', '', :n => 30) }
    end    
    x.report("commits(n=1)")   do
      100.times { repo.commits('HEAD', 1) }
    end
    x.report("commits(n=30)")   do
      100.times { repo.commits('HEAD', 30) }
    end    
    x.report("tree") do
      100.times { repo.tree('HEAD') }
    end  
    x.report("sub-nodes") do
      100.times { repo.tree('HEAD', ['app/models']).contents }
    end
    x.report("diff") do
      100.times do 
        text = repo.git.run '', 'diff', '', {}, ['076787', '31071b', '--', 'extensions/retro_blog/locales/app/en-GB.yml']
        Grit::Diff.list_from_string(repo, text).first
      end
    end  
  end
end


