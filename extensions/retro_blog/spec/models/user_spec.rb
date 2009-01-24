require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do

  before do 
    @user = User.new
  end

  it 'should have many blog-posts' do
    @user.should have_many(:blog_posts)
  end

end