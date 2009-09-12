#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
User.class_eval do
  has_many :requested_goals, 
    :class_name => 'Goal', 
    :foreign_key => 'requester_id',
    :dependent => :nullify
  has_many :created_stories, 
    :class_name => 'Story', 
    :foreign_key => 'created_by'
  has_many :created_story_events, 
    :class_name => 'StoryEvent', 
    :foreign_key => 'created_by'
  has_many :assigned_stories, 
    :class_name => 'Story', 
    :foreign_key => 'assigned_to',
    :dependent => :nullify
   
  protected
  
    def has_many_dependent_make_public_for_created_stories
      created_stories.each { |o| o.update_attribute :created_by, User.public_user.id }
    end
    before_destroy :has_many_dependent_make_public_for_created_stories

    def has_many_dependent_make_public_for_created_story_events
      created_story_events.each { |o| o.update_attribute :created_by, User.public_user.id }
    end
    before_destroy :has_many_dependent_make_public_for_created_story_events
  
  
end
