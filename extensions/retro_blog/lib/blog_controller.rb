#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class BlogController < ProjectAreaController
  retrospectiva_extension('retro_blog')

  menu_item :blog do |i|
    i.label = N_('Blog')
    i.rank = 30
    i.path = lambda do |project|
      project_blog_posts_path(project)
    end
  end

  require_permissions :blog_posts,
    :view    => ['index', 'show'],
    :create  => ['new', 'create'],
    :update  => ['update'],
    :delete  => ['destroy']

  enable_private_rss :only => :index
  
  before_filter :find_blog_post, :only => [:show, :comment, :edit, :update, :destroy]
  before_filter :new, :only => [:create]
  before_filter :load_categories, :only => [:index] 
  
  def index
    @blog_posts = Project.current.blog_posts.posted_by(params[:u]).categorized_as(params[:c]).paginate options_for_paginate
    respond_with_defaults(BlogPost)
  end
  
  def show
    @blog_comment = @blog_post.comments.new :author => cached_user_attribute(:name, 'Anonymous'), :email => cached_user_attribute(:email)
  end

  def new
    @blog_post = Project.current.blog_posts.new params[:blog_post]
  end
  
  def create
    if @blog_post.save
      flash[:notice] = _('Post was successfully created.')
      redirect_to project_blog_post_path(Project.current, @blog_post)
    else
      render :action => 'new'
    end
  end
  
  def edit
  end

  def update
    if @blog_post.update_attributes(params[:blog_post])          
      flash[:notice] = _('Post was successfully updated.')      
      redirect_to project_blog_post_path(Project.current, @blog_post)
    else
      render :action => 'edit'
    end    
  end

  def destroy
    if @blog_post.destroy
      flash[:notice] = _('Post was successfully deleted.')
    end
    redirect_to project_blog_posts_path(Project.current)
  end

  protected 

    def find_blog_post
      @blog_post = Project.current.blog_posts.find params[:id], :include => [:categories, :user, :comments]     
    end

    def load_categories
      @categories = Project.current.blog_posts.categories
    end

  private
  
    def options_for_paginate
      { :page => ( request.format.rss? ? 1 : params[:page] ), 
        :per_page => ( request.format.rss? ? 5 : nil ),
        :include => [:categories, :user, :comments],
        :order => 'blog_posts.created_at DESC' }
    end
end
