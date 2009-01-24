require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do

  before do 
    @project = Project.new :name => 'Project..Name'
  end

  it 'should have many wiki pages' do
    @project.should have_many(:wiki_pages)
  end

  it 'should cache existing wiki page titles' do
    @project.existing_wiki_page_titles.should == []
  end

  it 'should cache existing wiki page titles' do
    @project.existing_wiki_page_titles.should == []
  end  

  it 'should have a wiki-title' do
    @project.wiki_title.should == 'Project-Name'
  end  
  
end