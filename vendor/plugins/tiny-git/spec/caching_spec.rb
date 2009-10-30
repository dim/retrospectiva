require File.dirname(__FILE__) + '/helper'


describe 'TinyGit - Caching' do

  before do    
    TEST_REP.stub!(:run_command_without_cache).and_return('[RESULT]')    
  end
  
  it 'should cache responses temporarily and clear cache afterwards' do
    TEST_REP.should_receive(:run_command_without_cache).once.and_return('[RESULT]')

    TinyGit.result_cache.should == {}      
    TinyGit.cache do
      3.times { TEST_REP.rev_parse 'HEAD' }
      TinyGit.result_cache.should == { "/usr/bin/env git --git-dir=\"#{TEST_REP.git_dir}\" rev-parse \"HEAD\""=>"[RESULT]" }
    end
    TinyGit.result_cache.should == {}    
  end
  
end