#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class BlogComment < ActiveRecord::Base
  belongs_to :blog_post

  validates_presence_of :author
  validates_association_of :blog_post
  validates_as_email :email, :allow_blank => true
  validates_length_of :content, :in => 3..6000
  
  def serialize_only
    [:id, :author, :content, :created_at]    
  end
  
  def before_save
    blog_post.touch
  end

  def before_destroy
    blog_post.touch
  end
  
end
