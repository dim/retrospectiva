class StoryEvent < ActiveRecord::Base
  belongs_to :story
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  attr_accessible
  
  validates_association_of :creator, :story

  protected
  
    def before_validation_on_create
      self.created_by ||= User.current.public? ? nil : User.current.id
      true      
    end

end
