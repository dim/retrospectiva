#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
Project.class_eval do
  has_many :blog_posts, :dependent => :destroy do

    def categories
      records = find :all,
        :select => "DISTINCT #{ActsAsTaggableOn::Tag.quoted_table_name}.name",
        :joins => :categories,
        :order => "#{ActsAsTaggableOn::Tag.quoted_table_name}.name"
      records.map(&:name) 
    end
    
  end
  
  has_many :blog_comments, 
    :through => :blog_posts
end
