#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
Project.class_eval do
  has_many :sprints, :through => :milestones
end
