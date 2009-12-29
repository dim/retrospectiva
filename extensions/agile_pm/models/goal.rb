#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Goal < ActiveRecord::Base
  belongs_to :milestone
  belongs_to :sprint
  belongs_to :requester, :class_name => 'User'
  has_many   :stories

  Priority = Struct.new(:id, :name)

  cattr_reader :priorities
  @@priorities = [
    Priority.new(1, N_("Won't have")),
    Priority.new(2, N_("Could have")),
    Priority.new(3, N_("Should have")),
    Priority.new(4, N_("Must have"))
  ].freeze

  validates_presence_of :title
  validates_association_of :milestone
  validates_inclusion_of :priority_id, :in => priorities.map(&:id)
  
  attr_accessible :title, :description, :sprint_id, :priority_id, :requester_id

  def priority
    priorities[priority_id - 1]
  end
    
  protected
  
    def before_validation_on_create
      self.requester_id ||= User.current.id unless User.current.public?
      true
    end

    def validate
      if sprint and milestone and sprint.milestone != milestone
        errors.add :sprint_id, :invalid
      end
      errors.empty?
    end
  
end
