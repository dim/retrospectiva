require File.dirname(__FILE__) + '/../helper'


describe TinyGit::Object::Blob do
  
  def blob(ish = 'e7ae514edb4add418879ff2b9e4e0d5bad433d3c')
    @blob ||= TinyGit::Object::Blob.new(TEST_REP, ish)
  end
  
  it 'should be a blob' do
    blob.should be_blob
  end

  it 'should have a size' do
    blob.size.should == 540
  end

  it 'should have a content' do
    blob.contents.should =~ /class Author/
    blob.contents.size.should == 540
  end

  it 'should have a full sha' do
    blob('e7ae514').to_s.should == 'e7ae514'
    blob('e7ae514').sha.should == 'e7ae514edb4add418879ff2b9e4e0d5bad433d3c'    
  end

end