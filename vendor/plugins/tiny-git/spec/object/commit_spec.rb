require File.dirname(__FILE__) + '/../helper'


describe TinyGit::Object::Commit do
  
  def commit(ish = 'ae62392')
    @commit ||= TinyGit::Object::Commit.new(TEST_REP, ish)
  end
  
  it 'should be a commit' do
    commit.should be_commit
  end

  it 'should have a message' do
    commit('d369b5d').message.should == "Added/Deleted file"
  end

  it 'should correctly format multi-line messages' do
    commit.message.should == "Copied file\nMore details about it - some spaces afterwards"
  end

  it 'should have a summary' do
    commit.summary.should == 'Copied file'
  end

  it 'should have changes' do
    commit('d369b5d').should have(2).changes
  end

  it 'should have a committer' do
    commit.author.name.should == 'Dimitrij Denissenko' 
  end

  it 'should have an author' do
    commit.author.name.should == 'Dimitrij Denissenko' 
  end

  it 'should have a tree' do
    commit.tree.should have(2).children 
  end

  it 'can have a parent' do
    commit.parent.should be_kind_of(TinyGit::Object::Commit)
    commit.parent.sha.should == 'd369b5d8b895d95f7d8dab472e2db5a4e7ec8f9b'
  end

  it 'might not have parents' do
    commit('352fb14').parents.should be_empty
  end

end