#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class BlogCommentsController < ProjectAreaController
  retrospectiva_extension('retro_blog')
  helper BlogHelper

  menu_item :use => 'BlogController'

  require_permissions :blog_posts, 
    :comment => ['create']

  before_filter :find_blog_post
  
  def create
    @blog_comment = @blog_post.comments.new params[:blog_comment]
    if @blog_comment.save          
      cache_user_attributes!(:name => @blog_comment.author, :email => @blog_comment.email)
      flash[:notice] = _('Comment was successfully created.')      
      redirect_to project_blog_post_path(Project.current, @blog_post, :anchor => "comment#{@blog_comment.to_param}")
    else
      render :template => 'blog/show'
    end
  end

  def update
    @blog_comment = @blog_post.comments.find params[:id]
    @blog_comment.content = params[:value]
    @content = @blog_comment.save ? @blog_comment.content : @blog_comment.content_was
    respond_to(:js)  
  end

  def destroy
    @blog_comment = @blog_post.comments.find params[:id]
    @blog_comment.destroy
    flash[:notice] = _('Comment was successfully deleted.')
    redirect_to project_blog_post_path(Project.current, @blog_post)
  end

  protected 
    
    def find_blog_post
      @blog_post = Project.current.blog_posts.find params[:blog_post_id]     
    end

end
