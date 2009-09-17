#--
# Copyright (C) 2009 Dimitrij Denissenko
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
    :update  => ['edit', 'update'],
    :delete  => ['destroy']

  before_filter :check_freshness_of_index, :only => [:index]
  before_filter :find_blog_post, :only => [:show, :comment, :edit, :update, :destroy]
  before_filter :check_freshness_of_post, :only => [:show]
  before_filter :load_categories, :only => [:index] 
  
  def index
    @blog_posts = Project.current.blog_posts.posted_by(params[:u]).categorized_as(params[:c]).paginate options_for_paginate

    respond_to do |format|
      format.html
      format.rss  { render_rss(BlogPost) }
      format.xml  { render :xml => @blog_posts.to_xml }
    end
  end
  
  def show
    @blog_comment = @blog_post.comments.new :author => cached_user_attribute(:name, 'Anonymous'), :email => cached_user_attribute(:email)
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @blog_post.to_xml_with_comments }
    end
  end

  def new
    @blog_post = Project.current.blog_posts.new params[:blog_post]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @blog_post }
    end
  end
  
  def create
    @blog_post = Project.current.blog_posts.new params[:blog_post]

    respond_to do |format|
      if @blog_post.save
        flash[:notice] = _('Post was successfully created.')
        format.html { redirect_to [Project.current, @blog_post] }
        format.xml  { render :xml => @blog_post, :status => :created, :location => [Project.current, @blog_post] }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @blog_post.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
  end

  def update
    respond_to do |format|
      if @blog_post.update_attributes(params[:blog_post])          
        flash[:notice] = _('Post was successfully updated.')      
        format.html { redirect_to [Project.current, @blog_post] }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @blog_post.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @blog_post.destroy
    flash[:notice] = _('Post was successfully deleted.')
    
    respond_to do |format|
      format.html { redirect_to(project_blog_posts_path(Project.current)) }
      format.xml  { head :ok }
    end
  end

  protected 

    def find_blog_post
      @blog_post = Project.current.blog_posts.find params[:id], :include => [:categories, :user, :comments]     
    end

    def load_categories
      @categories = Project.current.blog_posts.categories
    end

    def check_freshness_of_index
      fresh_when :last_modified => Project.current.blog_posts.maximum(:updated_at)
    end

    def check_freshness_of_post
      fresh_when :etag => @blog_post, :last_modified => @blog_post.updated_at 
    end

  private
  
    def options_for_paginate
      { :page => ( request.format.rss? ? 1 : params[:page] ), 
        :per_page => ( request.format.rss? ? 5 : nil ),
        :total_entries => ( request.format.rss? ? 5 : nil ),
        :include => [:categories, :user, :comments],
        :order => 'blog_posts.created_at DESC' }
    end
end
