# coding:utf-8 
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BlogPost do
  fixtures :blog_posts, :blog_comments, :users, :projects

  describe 'an instance' do

    before do 
      @post = blog_posts(:release)
    end
  
    it 'should belong to project' do
      @post.should belong_to(:project)
    end
  
    it 'should belong to user' do
      @post.should belong_to(:user)
    end
  
    it 'should have many comments' do
      @post.should have_many(:comments)
      @post.should have(2).comments
    end
  
    it 'should validate association of project' do
      @post.should validate_association_of(:project)
    end
  
    it 'should validate association of user' do
      @post.should validate_association_of(:user)
    end
  
    it 'should validate presence of title' do
      @post.should validate_presence_of(:title)
    end
  
    it 'should validate presence of content' do
      @post.should validate_presence_of(:content)
    end

  end

  describe 'generating a preview' do

    before do 
      @post = blog_posts(:release)
    end
    
    it 'should generate a preview' do
      BlogPost.preview_length = 100 
      @post.preview.should == "h2. Headline\n\nDek ec hodiaua malprofitanto. Speco prirespondi diskriminacio ve duo, sen ho jota  ..."
    end

    it 'should try remove the last text paragraph' do
      BlogPost.preview_length = 180 
      @post.preview.should == "h2. Headline\n\nDek ec hodiaua malprofitanto. Speco prirespondi diskriminacio ve duo, sen ho jota kauze tutampleksa,\nhej jesigi kilogramo po."
    end

    it 'should try remove orphaned headlines' do
      BlogPost.preview_length = 300 
      @post.preview.should == "h2. Headline\n\nDek ec hodiaua malprofitanto. Speco prirespondi diskriminacio ve duo, sen ho jota kauze tutampleksa,\nhej jesigi kilogramo po.\n\nNula otek neoficiala ha poa, plue otek jugoslavo io, igi trans deloke helpverbo vi."
    end
        
  end

  describe 'before save' do

    before do 
      @post = blog_posts(:release)
    end
    
    it 'should normalize categories' do
      @post.category_list = ['downcase', 'UPCASE', 'Caps', 'CamelCase', 'Split words'].join(', ')
      @post.valid?
      @post.category_list.should == ['Downcase', 'Upcase', 'Caps', 'Camel Case', 'Split Words']
    end
    
    it 'should validate that assigned user is not public' do
      @post.user = users(:Public)
      @post.should have(1).error_on(:user_id)      
    end
        
  end

  describe 'before create' do

    before do
      User.stub!(:current).and_return(users(:agent))
      @post = BlogPost.new
    end
    
    it 'should automatically assign the logged-in user' do
      @post.user.should be_nil      
      @post.valid?
      @post.user.should == users(:agent)      
    end
        
  end


  describe 'previewable' do  
      
    before do 
      @post = blog_posts(:release)
    end

    describe 'channel' do
      before do
        @channel = BlogPost.previewable.channel(:project => projects(:retro))
      end
      
      it 'should correct attributes' do
        @channel.name.should == 'blog'
        @channel.title.should == 'Blog'
        @channel.description.should == 'Blog for Retrospectiva'
        @channel.link.should == 'http://test.host/projects/retrospectiva/blog'
      end
    end

    describe 'items' do
      before do
        @item = @post.previewable(:project => projects(:retro))
      end
      
      it 'should correct attributes' do
        @item.title.should == @post.title
        @item.description.should == @post.preview
        @item.link.should == "http://test.host/projects/retrospectiva/blog/#{@post.id}"
        @item.date.should == @post.created_at
      end      
    end
    
  end

  
  describe 'the class' do
    
    it 'should find records by categories' do
      BlogPost.categorized_as('Other').should have(1).record  
      BlogPost.categorized_as('General').should have(2).records  
      BlogPost.categorized_as('Missing').should have(:no).records  
    end
    
    it 'should find records by user' do
      BlogPost.posted_by(users(:agent).id).should have(3).records  
      BlogPost.posted_by(0).should have(:no).records  
    end

    it 'should search for records' do
      BlogPost.full_text_search('neoficiala').should == [blog_posts(:release)]
      BlogPost.full_text_search('welcome').should == [blog_posts(:welcome)]  
    end

  end

end
