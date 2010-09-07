class StoryProgressUpdate < ActiveRecord::Base
  belongs_to :story

  validates_association_of :story
  validates_uniqueness_of :created_on, :scope => :story_id
  validates_inclusion_of :percent_completed, :in => [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]

  class << self
    
    def find_or_initialize(created_on, percent_completed)
      find_or_initialize_by_created_on(created_on).tap do |record|
        record.percent_completed = percent_completed
      end    
    end
    
    def update_or_create(created_on, percent_completed)
      find_or_initialize(created_on, percent_completed).save
    end
  
  end
  
end
