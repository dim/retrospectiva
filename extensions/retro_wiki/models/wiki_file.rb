#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class WikiFile < Attachment
  belongs_to :project

  validates_length_of :wiki_title, :in => 2..80
  validates_format_of :wiki_title, :with => /\A\w( ?\w+)*\w\Z/
  validates_association_of :project
  validates_uniqueness_of :wiki_title, :case_sensitive => false, :scope => :project_id
  
  def format
    File.extname(file_name).gsub(/\W/, '')
  end
  
  def format?
    format.present?
  end
  
  def to_param
    wiki_title
  end

end
