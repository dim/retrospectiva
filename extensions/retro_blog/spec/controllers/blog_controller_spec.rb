require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BlogController do
  it_should_behave_like EveryProjectAreaController

  before do
    @project = permit_access_with_current_project! :name => 'Retro', :wiki_title => 'Retro'
    @user = stub_current_user! :permitted? => true, :projects => [@project]
    @posts_proxy = @project.stub_association!(:blog_posts)
    @posts_proxy.stub!(:posted_by).and_return(@posts_proxy)
    @posts_proxy.stub!(:categorized_as).and_return(@posts_proxy)
    @posts_proxy.stub!(:maximum)
    
    controller.stub!(:cached_user_attribute).with(:name, 'Anonymous').and_return('User Name')
    controller.stub!(:cached_user_attribute).with(:email).and_return('user@host.com')
  end

  describe 'GET /index' do
    
    before do
      @posts = [mock_model(BlogPost), mock_model(BlogPost)]
      @posts_proxy.stub!(:paginate).and_return(@posts)

      @categories = ['News', 'Releases']
      @posts_proxy.stub!(:categories).and_return(@categories)
    end
    
    def do_get(options = {})
      get :index, options.merge(:project_id => @project.to_param)
    end
    
    it 'should check the freshness' do
      @posts_proxy.should_receive(:maximum).with(:updated_at)
      do_get
    end
    
    it 'should load the posts' do
      @posts_proxy.should_receive(:posted_by).with('1').and_return(@posts_proxy) 
      @posts_proxy.should_receive(:categorized_as).with('News').and_return(@posts_proxy) 
      @posts_proxy.should_receive(:paginate).with(
        :page => params[:page],
        :include => [:categories, :user, :comments],
        :per_page=>nil,
        :order=>'blog_posts.created_at DESC',
        :total_entries=>nil
      ).and_return(@posts) 
      do_get(:u => '1', :c => 'News')
      assigns[:blog_posts].should == @posts 
    end
    
    it 'should load the categories' do
      @posts_proxy.should_receive(:categories).with().and_return(@categories)
      do_get
    end

    it "should render the template" do
      do_get
      response.should be_success
      response.should render_template(:index)
    end

    it 'should indicate RSS download'

  end


  describe 'GET /index.rss' do
    
    it 'is pending'
    
  end

  describe 'GET /show' do
    
    before do
      @blog_post = mock_model(BlogPost, :updated_at => 10.minutes.ago)
      @comment = mock_model(BlogComment)
      @comments_proxy = @blog_post.stub_association!(:comments, :new => @comment)      
      @posts_proxy.stub!(:find).and_return(@blog_post)
    end
    
    def do_get(options = {})
      get :show, options.merge(:id => '1', :project_id => @project.to_param)
    end

    it 'should load the post' do
      @posts_proxy.should_receive(:find).with('1', :include => [:categories, :user, :comments]).and_return(@blog_post)
      do_get
      assigns[:blog_post].should == @blog_post
    end

    it 'should prepare a comment' do
      @comments_proxy.should_receive(:new).with(:author => 'User Name', :email => 'user@host.com').and_return(@comment)
      do_get
    end
        
    it "should render the template" do
      do_get
      response.should be_success
      response.should render_template(:show)
    end

  end


  describe 'GET /new' do
    
    before do
      @blog_post = mock_model(BlogPost)
      @posts_proxy.stub!(:new).and_return(@blog_post)
    end
    
    def do_get(options = {})
      get :new, options.merge(:project_id => @project.to_param)
    end

    it 'should build the post' do
      @posts_proxy.should_receive(:new).with(nil).and_return(@blog_post)
      do_get
      assigns[:blog_post].should == @blog_post
    end

    it "should render the template" do
      do_get
      response.should be_success
      response.should render_template(:new)
    end
    
  end


  describe 'POST /create' do
    
    before do
      @blog_post = mock_model(BlogPost, :save => true)
      @posts_proxy.stub!(:new).and_return(@blog_post)
    end
    
    def do_post
      post :create, :blog_post => {}, :project_id => @project.to_param
    end

    it 'should build the post' do
      @posts_proxy.should_receive(:new).with({}).and_return(@blog_post)
      do_post
      assigns[:blog_post].should == @blog_post
    end
    
    describe 'when save is successful' do
      
      before do
        @blog_post.should_receive(:save).with().and_return(true)
      end      

      it 'should redirect to show' do
        do_post
        response.should redirect_to(project_blog_post_path(@project, @blog_post))
      end

    end

    describe 'when save is NOT successful' do

      before do
        @blog_post.should_receive(:save).and_return(false)        
      end      

      it "should render the new screen" do
        do_post
        response.should be_success
        response.should render_template(:new)
      end      
      
    end
    
  end


  describe 'GET /edit' do
    
    before do
      @blog_post = mock_model(BlogPost)
      @posts_proxy.stub!(:find).and_return(@blog_post)
    end
    
    def do_get(options = {})
      get :edit, options.merge(:id => '1', :project_id => @project.to_param)
    end

    it 'should load the post' do
      @posts_proxy.should_receive(:find).with('1', :include => [:categories, :user, :comments]).and_return(@blog_post)
      do_get
      assigns[:blog_post].should == @blog_post
    end

    it "should render the template" do
      do_get
      response.should be_success
      response.should render_template(:edit)
    end      
    
  end


  describe 'PUT /update' do
    
    before do
      @blog_post = mock_model(BlogPost, :update_attributes => true)
      @posts_proxy.stub!(:find).and_return(@blog_post)
    end
    
    def do_put
      put :update, :id => '1', :blog_post => {}, :project_id => @project.to_param
    end

    it 'should load the post' do
      @posts_proxy.should_receive(:find).with('1', :include => [:categories, :user, :comments]).and_return(@blog_post)
      do_put
      assigns[:blog_post].should == @blog_post
    end

    describe 'when update is successful' do
      
      it 'should redirect to show' do
        @blog_post.should_receive(:update_attributes).with({}).and_return(true)        
        do_put
        response.should redirect_to(project_blog_post_path(@project, @blog_post))
      end
            
    end

    describe 'when update is NOT successful' do

      it "should render the edit screen" do
        @blog_post.should_receive(:update_attributes).with({}).and_return(false)        
        do_put
        response.should be_success
        response.should render_template(:edit)
      end      

    end
    
  end


  describe 'DELETE /destroy' do
    
    before do
      @blog_post = mock_model(BlogPost, :destroy => true)
      @posts_proxy.stub!(:find).and_return(@blog_post)
    end
    
    def do_delete
      delete :destroy, :id => '1', :project_id => @project.to_param
    end

    it 'should load the page' do
      @posts_proxy.should_receive(:find).with('1', :include => [:categories, :user, :comments]).and_return(@blog_post)
      do_delete
      assigns[:blog_post].should == @blog_post
    end

    it "should delete the record" do
      @blog_post.should_receive(:destroy).and_return(true)
      do_delete
    end

    it 'should redirect to index page' do
      do_delete
      response.should redirect_to(project_blog_posts_path(@project))
    end
    
  end


end
