require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do
  fixtures :projects, :wiki_pages

  def new_project
    @project ||= Project.new :name => 'Project..Name'    
  end

  def project
    projects(:retro)    
  end

  it 'should have many wiki pages' do
    project.should have_many(:wiki_pages)
  end

  it 'should cache existing wiki page titles' do
    project.existing_wiki_page_titles.should == ['Retrospectiva', 'New Page']
  end

  it 'can refresh its cache' do
    project.reset_existing_wiki_page_titles!
    project.existing_wiki_page_titles.sort.should == ['Intro', 'New Page', 'Retrospectiva']
  end  

  it 'should have a wiki-title' do
    project.wiki_title.should == 'Retrospectiva'
    new_project.wiki_title.should == 'Project-Name'
  end  

  it 'can generate a custom wiki-title' do
    new_project.wiki_title('Something / Else').should == 'Something - Else'
  end  

  it 'should rename the home page when a project is renamed' do
    project.name = 'Pop'
    project.save.should be(true)
    wiki_pages(:home).title.should == 'Pop'
    project.wiki_pages.map(&:title).sort.should == ['Intro', 'New Page', 'Pop']
  end  
  
end