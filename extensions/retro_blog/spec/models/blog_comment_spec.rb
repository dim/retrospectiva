require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BlogComment do
  fixtures :blog_posts, :blog_comments, :users, :projects

  describe 'an instance' do

    before do 
      @comment = BlogComment.new
    end
  
    it 'should belong to a post' do
      @comment.should belong_to(:blog_post)
    end
  
    it 'should validate association of post' do
      @comment.should validate_association_of(:blog_post)
    end
  
    it 'should validate presence of author' do
      @comment.should validate_presence_of(:author)
    end
  
    it 'should validate presence of content' do
      @comment.should have(1).error_on(:content)
    end

    it 'should validate correct email' do
      @comment.email = ''
      @comment.should have(:no).errors_on(:email)
      @comment.email = 'invalid email'      
      @comment.should have(1).error_on(:email)
    end

    it 'should validate maximal length of content' do
      @comment.content = 'A' * 6000
      @comment.should have(:no).errors_on(:content)
      @comment.content = 'A' * 6001
      @comment.should have(1).error_on(:content)
    end

    it 'should touch the blog post on save' do
      blog_comments(:release_negative).save.should be_true
      blog_posts(:release).updated_at.should > 1.minute.ago
    end

    it 'should touch the blog post on destroy' do
      blog_comments(:release_negative).destroy
      blog_posts(:release).updated_at.should > 1.minute.ago
    end

  end

end
