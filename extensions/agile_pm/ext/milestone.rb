#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
Milestone.class_eval do
  has_many :sprints, :dependent => :destroy
  has_many :goals, :dependent => :destroy

  named_scope :in_order_of_relevance, 
    :order => %Q(
      CASE WHEN started_on IS NULL THEN 1 ELSE 0 END,
      CASE WHEN finished_on IS NULL THEN 0 ELSE 1 END,
      started_on
    ).squish   
  
end
