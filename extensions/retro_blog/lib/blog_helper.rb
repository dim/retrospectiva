#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
module BlogHelper

  def include_blog_stylesheet
    content_for :header do
      x_stylesheet_link_tag('retro_blog')      
    end
  end

  def category_links(post)
    post.categories.map do |category|
      link_to h(category.name), project_blog_posts_path(Project.current, params.only(:u).merge(:c => category.name))
    end.join(', ')
  end

end
