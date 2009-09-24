require File.dirname(__FILE__) + '/helper'


describe TinyGit::Change do

  def do_parse
    @changes ||= TinyGit::Change.parse(log)  
  end
  
  def log
    TEST_REP.log('d369b5', :raw => true, :max_count => 1)    
  end

  it 'should parse the file-changes' do
    do_parse.should have(2).records 
  end
  
  it 'should extract and store all relevant information' do    
    do_parse[0].type.should == 'A' 
    do_parse[0].a_mode.should == '000000'
    do_parse[0].b_mode.should == '100644'
    do_parse[0].a_commit.should == '0000000'
    do_parse[0].b_commit.should == '8acdd82'
    do_parse[0].a_path.should == 'lib/tiny/VERSION.txt'
    do_parse[0].b_path.should be_nil

    do_parse[1].type.should == 'D'
    do_parse[1].a_mode.should == '100644'
    do_parse[1].b_mode.should == '000000'
    do_parse[1].a_commit.should == '75c3e7a'
    do_parse[1].b_commit.should == '0000000'
    do_parse[1].a_path.should == 'lib/tiny/caching.rb'
    do_parse[1].b_path.should be_nil
  end
  
end

