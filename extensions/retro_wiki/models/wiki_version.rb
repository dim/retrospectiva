#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class WikiVersion < ActiveRecord::Base 
  belongs_to :wiki_page
  belongs_to :user
  
  validates_presence_of :content, :author
  validates_association_of :wiki_page
  
  delegate :title, :versions, :to => :wiki_page

  def newer_versions
    versions[number..-1].size + 1
  end

  def older_versions
    number - 1
  end
    
  def number
    @number ||= versions.index(self) + 1
  end
  
  def updated_at
    created_at
  end
  
  def to_param
    title
  end
  
  def historic?
    true
  end
  
end
