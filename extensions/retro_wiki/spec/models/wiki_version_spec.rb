require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WikiVersion do
  fixtures :wiki_pages, :wiki_versions, :projects

  before do 
    @version = wiki_versions(:intro_2nd)
  end

  it 'should belong-to a wiki page' do
    @version.should belong_to(:wiki_page)
  end

  it 'can belong-to a user' do
    @version.should belong_to(:user)
  end
  
  it 'should validate presence of content' do
    @version.should validate_presence_of(:content)
  end

  it 'should validate presence of author' do
    @version.should validate_presence_of(:author)
  end

  it 'should have a title (the same as the associated page)' do
    @version.title.should == 'Intro'
  end

  it 'should have sibling versions' do
    @version.should have(3).versions
  end

  it 'should use the title as parameter name' do
    @version.to_param.should == @version.title
  end
  
  it 'should corrently indicate the version number' do
    wiki_versions(:intro_1st).number.should == 1
    wiki_versions(:intro_2nd).number.should == 2
    wiki_versions(:intro_3rd).number.should == 3
  end      

  it 'should corrently indicate the amount of older versions' do
    wiki_versions(:intro_1st).older_versions.should == 0
    wiki_versions(:intro_2nd).older_versions.should == 1
    wiki_versions(:intro_3rd).older_versions.should == 2
  end      

  it 'should corrently indicate the amount of newer versions' do
    wiki_versions(:intro_1st).newer_versions.should == 3
    wiki_versions(:intro_2nd).newer_versions.should == 2
    wiki_versions(:intro_3rd).newer_versions.should == 1
  end      
  
end