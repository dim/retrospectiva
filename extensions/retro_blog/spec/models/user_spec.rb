require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  fixtures :users, :groups, :projects

  before do 
    @user = users(:Public)
  end

  it 'should have many blog-posts' do
    @user.should have_many(:blog_posts)
  end

  describe 'Public user' do
    
    before do
      Project.stub!(:current).and_return(projects(:retro))
    end
    
    it 'should never be permitted to create posts' do
      @user.send(:project_permission?, projects(:retro), :blog_posts, :create).should be(true)      
      @user.send(:permitted?, :blog_posts, :create).should be(false)      
    end
    
  end
end