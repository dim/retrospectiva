require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BlogCommentsController do
  it_should_behave_like EveryProjectAreaController

  before do
    @project = permit_access_with_current_project! :name => 'Retro', :wiki_title => 'Retro'
    @user = stub_current_user! :permitted? => true, :projects => [@project]
    
    @blog_post = mock_model(BlogPost)

    @posts_proxy = @project.stub_association! :blog_posts,
      :find => @blog_post
    @comments_proxy = @blog_post.stub_association! :comments
  end

  describe 'POST /create' do
    
    before do
      @blog_comment = mock_model(BlogComment, :author => 'Me', :email => 'me@home', :save => true)
      @comments_proxy.stub!(:new).and_return(@blog_comment)
      controller.stub!(:cache_user_attributes!)
    end
    
    def do_post
      post :create, :blog_post_id => @blog_post.to_param, :project_id => @project.to_param, :blog_comment => {}
    end

    it 'should find the post' do
      @posts_proxy.should_receive(:find).with(@blog_post.to_param).and_return(@blog_post)
      do_post
      assigns[:blog_post].should == @blog_post
    end

    it 'should build the comment' do
      @comments_proxy.should_receive(:new).with({}).and_return(@blog_comment)
      do_post
      assigns[:blog_comment].should == @blog_comment
    end
    
    describe 'when save is successful' do

      before do
        @blog_comment.should_receive(:save).with().and_return(true)        
      end
      
      it 'should redirect to post' do
        do_post
        response.should redirect_to(project_blog_post_path(@project, @blog_post, :anchor => "comment#{@blog_comment.to_param}"))
      end

      it 'should cache the author setting' do
        controller.should_receive(:cache_user_attributes!).with(:name => 'Me', :email => 'me@home')
        do_post
      end      

    end

    describe 'when save is NOT successful' do

      before do
        @blog_comment.should_receive(:save).with().and_return(false)        
      end

      it "should render the form again" do
        do_post
        response.should be_success
        response.should render_template('blog/show')
      end      
      
      it 'should NOT cache the author setting' do
        controller.should_not_receive(:cache_user_attributes!)
        do_post
      end      

    end
    
  end



  describe 'XHR PUT /update' do
    
    before do
      @blog_comment = mock_model(BlogComment, :content => 'IS', :content= => 'IS', :content_was => 'WAS', :save => true)
      @comments_proxy.stub!(:find).and_return(@blog_comment)
    end
    
    def do_put
      xhr :put, :update, :blog_post_id => @blog_post.to_param, :id => @blog_comment.to_param, :project_id => @project.to_param, :value => 'SET-TO'
    end

    it 'should find the post' do
      @posts_proxy.should_receive(:find).with(@blog_post.to_param).and_return(@blog_post)
      do_put
      assigns[:blog_post].should == @blog_post
    end

    it 'should find the comment' do
      @comments_proxy.should_receive(:find).with(@blog_comment.to_param).and_return(@blog_comment)
      do_put
      assigns[:blog_comment].should == @blog_comment
    end

    it 'should update the comment' do
      @blog_comment.should_receive(:content=).with('SET-TO')
      do_put
    end
    
    describe 'when save is successful' do

      before do
        @blog_comment.should_receive(:save).with().and_return(true)        
      end
      
      it 'should return the new value' do
        do_put
        assigns[:content].should == 'IS'
      end

    end

    describe 'when save is NOT successful' do

      before do
        @blog_comment.should_receive(:save).with().and_return(false)        
      end
      
      it 'should return the previous value' do
        do_put
        assigns[:content].should == 'WAS'
      end

    end
    
  end



  describe 'DELETE /destroy' do
    
    before do
      @blog_comment = mock_model(BlogComment, :destroy => true)
      @comments_proxy.stub!(:find).and_return(@blog_comment)
    end
    
    def do_delete
      delete :destroy, :blog_post_id => @blog_post.to_param, :id => '1', :project_id => @project.to_param
    end

    it 'should find the post' do
      @posts_proxy.should_receive(:find).with(@blog_post.to_param).and_return(@blog_post)
      do_delete
      assigns[:blog_post].should == @blog_post
    end

    it 'should delete the comment' do
      @blog_comment.should_receive(:destroy).with().and_return(true)
      do_delete
    end

    it 'should return to the post' do
      do_delete
      response.should redirect_to(project_blog_post_path(@project, @blog_post))
    end
    
  end

end
