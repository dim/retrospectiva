#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class BlogComment < ActiveRecord::Base
  belongs_to :blog_post

  validates_presence_of :author, :content
  validates_association_of :blog_post
  validates_as_email :email, :allow_blank => true
  validates_length_of :content, :maximum => 6000
end
