#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
User.class_eval do
  has_many :blog_posts, 
    :order => 'blog_posts.created_at DESC', 
    :dependent => :destroy
end
