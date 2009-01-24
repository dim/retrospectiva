require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do
  fixtures :projects, :blog_posts, :tags, :taggings

  before do 
    @project = projects(:retro)
  end

  it 'should have many blog-posts' do
    @project.should have_many(:blog_posts)
  end

  it 'should have many blog-comments (through posts)' do
    @project.should have_many(:blog_comments)
  end

  it 'should have many blog categories' do
    @project.blog_posts.categories.should == ['General', 'Release']
    projects(:sub).blog_posts.categories.should == ['Other']
  end

end