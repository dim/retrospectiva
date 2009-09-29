require 'benchmark'

GDIR = File.expand_path(File.dirname(__FILE__) + '/../../../.git')
TMS  = 1000

def git(command)
  `git --git-dir='#{GDIR}' #{command}`
end


2.times { puts }
puts 'Getting a node\'s latest revision'
 
Benchmark.benchmark(' ' * 20 + Benchmark::Tms::CAPTION, 20) do |b|
  b.report('git log') do
    TMS.times { git "log --max-count=1 --pretty=format:%H 4d52248c681483269b011e79d8cd233423593b0f -- RUNNING_TESTS" }
  end
 
  b.report('git rev-list') do
    TMS.times { git "rev-list --max-count=1 4d52248c681483269b011e79d8cd233423593b0f -- RUNNING_TESTS" }
  end
end
