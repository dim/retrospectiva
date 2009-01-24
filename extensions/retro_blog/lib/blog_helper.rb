#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
module BlogHelper

  def include_blog_stylesheet
    layout_markers[:header] << x_stylesheet_link_tag('retro_blog')
  end

  def category_links(post)
    post.categories.map do |category|
      link_to h(category.name), project_blog_posts_path(Project.current, params.only(:u).merge(:c => category.name))
    end.join(', ')
  end

#  def post_maintenance_links(post)
#    links = []
#    links << content_tag('dd', ipeh_for_post_title(post))
#    links << content_tag('dd', ipeh_for_post_content(post))
#    links << content_tag('dd', ipeh_for_post_categories(post))
#
#    if User.current.admin?
#      delete_opts = {:confirm => _('Really delete this post?'), :method => 'post'}
#      link = link_to(_('Delete post'), {:action => 'delete', :id => post}, delete_opts)
#      links << content_tag('dd', link)
#    end    
#    links    
#  end
#
#  def comment_maintenance_links(comment)
#    links = []
#    links << ipeh_for_comment_content(comment)
#
#    delete_opts = {:confirm => _('Really delete this comment?'), :method => 'post'}
#    links << link_to(_('Delete'), {:action => 'delete_comment', :id => comment}, delete_opts)
#    
#    links.join(' | ')
#  end
#
#  def ipeh_for_comment_content(comment)
#    tag_id = "blog-comment-content-#{comment.id}"
#    options = {:rows => 4, :no_wrap => true}
#    options[:load_text_url] = {:action => 'show_blog_comment_content', :id => comment.id}
#    options[:url] = {:action => 'edit_blog_comment_content', :id => comment.id}
#    inplace_editor_handle(_('Edit'), tag_id, options)
#  end
#
#  def ipeh_for_post_title(post)
#    tag_id = 'blog-post-title'
#    options = {:no_wrap => true}
#    options[:url] = {:action => 'edit_blog_post_title', :id => post.id}
#    inplace_editor_handle(_('Edit title'), tag_id, options)
#  end
#
#  def ipeh_for_post_content(post)
#   tag_id = 'blog-post-content'
#   options = {:rows => 12, :no_wrap => true}
#   options[:load_text_url] = {:action => 'show_blog_post_content', :id => post.id}
#   options[:url] =           {:action => 'edit_blog_post_content', :id => post.id}
#
#   inplace_editor_handle(_('Edit content'), tag_id, options)
#  end
#
#  def ipeh_for_post_categories(post)
#   tag_id = 'blog-post-categories'
#   options = {:no_wrap => true}
#   options[:load_text_url] = {:action => 'show_blog_post_categories', :id => post.id}
#   options[:url] =           {:action => 'edit_blog_post_categories', :id => post.id}
#
#   inplace_editor_handle(_('Edit categories'), tag_id, options)
#  end
#
#  def post_editable?(post)
#    User.current.admin? || post.user_id == User.current.id
#  end

end
