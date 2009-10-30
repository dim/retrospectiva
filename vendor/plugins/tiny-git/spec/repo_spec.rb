require File.dirname(__FILE__) + '/helper'


describe TinyGit::Repo do

  def new_repo(path = 'test_rep')    
    @new_repo ||= TinyGit::Repo.new File.join(File.dirname(__FILE__), path) #, Logger.new(STDOUT)
  end

  it 'should automatically determine the git-dir' do
    new_repo.git_dir.should == './spec/test_rep/.git' 
  end
  
  it 'should automatically determine if the git-dir was passed' do
    new_repo('test_rep/.git').git_dir.should == './spec/test_rep/.git' 
  end  
  
  it 'should list trees' do
    tree = new_repo.ls_tree 'ae62392290e2d393df03deac0310747c55012b12', '--', 'lib/tiny', 'lib/tiny/*', :t => true 
    tree.should == [
      {:type=>"tree", :mode=>"040000", :path=>"lib", :sha=>"b090a05f9f70e6af595610118a817c2e51760c65"}, 
      {:type=>"tree", :mode=>"040000", :path=>"lib/tiny", :sha=>"637391301aa7c1d6a33c7913ec0784d64226a951"}, 
      {:type=>"blob", :mode=>"100644", :path=>"lib/tiny/VERSION.txt", :sha=>"8acdd82b765e8e0b8cd8787f7f18c7fe2ec52493"}, 
      {:type=>"blob", :mode=>"100644", :path=>"lib/tiny/author.rb", :sha=>"e7ae514edb4add418879ff2b9e4e0d5bad433d3c"},
      {:type=>"blob", :mode=>"100644", :path=>"lib/tiny/change.rb", :sha=>"4d82580308dd90871e8e668f16793d75398f08bb"},
      {:type=>"blob", :mode=>"100644", :path=>"lib/tiny/commands.rb", :sha=>"72e591703007841eaf95b4d3f4b138050d77c833"},
      {:type=>"blob", :mode=>"100644", :path=>"lib/tiny/object.rb", :sha=>"ce51f92eaaaf1bd408da7f906c6c21e28f1e3483"},
      {:type=>"tree", :mode=>"040000", :path=>"lib/tiny/object", :sha=>"02e26d786bd333b7a5a5e9e40582aef0381541a4"},
      {:type=>"blob", :mode=>"100644", :path=>"lib/tiny/repo.rb", :sha=>"6f499c1b1f9ca99c288ad9e7449220675906dda2"}
    ]
  end

  it 'should parse revisions' do
    new_repo.rev_parse('352fb14:lib/').should == 'd0c7d1919d3dde0b23cdd5e036fdb3af9822c73b'
  end

  it 'should list revisions' do
    new_repo.rev_list('164a359..ae62392').should == ["ae62392290e2d393df03deac0310747c55012b12", "d369b5d8b895d95f7d8dab472e2db5a4e7ec8f9b"]
  end

  it 'should cat files' do
    new_repo.cat_file('164a359', :t => true).should == "commit"
    new_repo.cat_file('164a359', :s => true).should == '282'
    new_repo.cat_file('commit', 'ae62392').size.should == 320
    new_repo.cat_file('commit', 'ae62392').should =~ /\n{1}\Z/m
  end

  it 'should query the log' do
    new_repo.cat_file('164a359', :t => true).should == "commit"
    new_repo.cat_file('164a359', :s => true).should == '282'
    new_repo.cat_file('commit', 'ae62392').size.should == 320
    new_repo.cat_file('commit', 'ae62392').should =~ /\n{1}\Z/m
  end

  it 'should catch and re-raise GIT errors' do
    msg = "[128] fatal: Not a valid object name 9999999 (/usr/bin/env git --git-dir=\"./spec/test_rep/.git\" cat-file -s \"9999999\")" 
    lambda { new_repo.cat_file('9999999', :s => true) }.should raise_error(TinyGit::GitExecuteError, msg)
  end  

  it 'should handle unusual file name variations' do
    tree = new_repo.ls_tree 'HEAD', '--', 'res/this file\'s name is (a "little") strange.txt' 
    tree.should == [{:type=>"blob", :mode=>"100644", :path=>'res/this file\'s name is (a "little") strange.txt', :sha=>"bb590f885cfa35e3a4bdb3396da8b14b4904d045"}]

    tree = new_repo.ls_tree 'HEAD', '--', 'res/another \ one.txt'
    tree.should == [{:type=>"blob", :mode=>"100644", :path=> 'res/another \ one.txt', :sha=>"bb590f885cfa35e3a4bdb3396da8b14b4904d045"}]
  end
  
end

