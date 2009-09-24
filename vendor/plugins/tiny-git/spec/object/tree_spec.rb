require File.dirname(__FILE__) + '/../helper'


describe TinyGit::Object::Tree do
  
  def tree(ish = '637391301aa7c1d6a33c7913ec0784d64226a951')
    @tree ||= TinyGit::Object::Tree.new(TEST_REP, ish)
  end
  
  it 'should be a tree' do
    tree.should be_tree
  end

  it 'can have blobs/files' do
    tree.should have(6).blobs
  end

  it 'can have sub-trees' do
    tree.trees.should have(1).items
  end

  it 'should have a full sha' do
    tree('b090a05').to_s.should == 'b090a05'
    tree('b090a05').sha.should == 'b090a05f9f70e6af595610118a817c2e51760c65'    
  end

end