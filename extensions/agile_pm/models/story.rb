class Story < ActiveRecord::Base
  belongs_to :sprint
  belongs_to :goal
  belongs_to :creator, :class_name => 'User', :foreign_key => 'created_by'
  belongs_to :assigned, :class_name => 'User', :foreign_key => 'assigned_to'
  has_many :progress_updates, 
    :class_name => 'StoryProgressUpdate',
    :order => 'story_progress_updates.created_on'
  has_many :events, 
    :class_name => 'StoryEvent',
    :order => 'story_events.created_at'
  has_many :status_updates, 
    :class_name => 'StoryStatusUpdate',
    :order => 'story_events.created_at'
  has_many :comments, 
    :class_name => 'StoryComment',
    :order => 'story_events.created_at'
  has_many :revisions, 
    :class_name => 'StoryRevision',
    :order => 'story_events.created_at'

  validates_length_of :title, :in => 1..160
  validates_length_of :description, :maximum => 5000, :allow_nil => true
  validates_association_of :sprint, :creator
  validates_numericality_of :estimated_hours, 
    :integer_only => true,
    :greater_than_or_equal_to => 0
  validates_numericality_of :revised_hours, 
    :integer_only => true,
    :greater_than_or_equal_to => 0
  
  attr_accessible :title, :description, :estimated_hours, :goal_id
  
  named_scope :active,
    :conditions => ['started_at IS NOT NULL AND completed_at IS NULL AND assigned_to IS NOT NULL']
  named_scope :pending,
    :conditions => ['started_at IS NULL OR assigned_to IS NULL']
  named_scope :completed,
    :conditions => ['completed_at IS NOT NULL']
  named_scope :in_default_order, 
    :include => [:goal], 
    :order => "CASE goals.priority_id WHEN NULL THEN 0 ELSE goals.priority_id END DESC, stories.created_at"
  
  
  def percent_completed
    progress_updates.last ? progress_updates.last.percent_completed : 0
  end
  
  def started?
    started_at.present?
  end

  def pending?
    not started? or not assigned?
  end

  def orphanned?
    started? and not assigned?
  end

  def completed?
    completed_at.present?
  end

  def assigned?
    assigned.present?
  end
  
  def in_progress?
    started? and assigned? and not completed?
  end
  alias_method :active?, :in_progress?
  
  def assigned_to?(user)
    assigned == user
  end
  
  def accept!(user = User.current)
    self.assigned = user
    self.started_at ||= Time.zone.now    
  end

  def complete!(user = User.current)
    self.assigned = user
    self.completed_at = Time.zone.now    
  end

  def reopen!(user = User.current)
    self.assigned = user
    self.completed_at = nil
  end
  
  def remaining_hours(date)
    revised_hours * (100 - progress_index[date]) / 100.0        
  end

  def progress_index
    @progress_index ||= ProgressIndex.new(progress_updates)
  end
  
  def status_on(date)
    if started_at.nil? or date < started_at.to_date
      :pending
    elsif completed_at.present? and date > completed_at.to_date
      :completed
    else
      :active
    end
  end
  
  def current_status
    status_on(Time.zone.today)
  end
  
  protected
    
    class ProgressIndex < ActiveSupport::OrderedHash
      
      def initialize(progress_updates)
        super()
        progress_updates.each do |update| 
          self[update.created_on] = update.percent_completed
        end
      end
      
      protected
      
        def default(key)
          return 0 unless key.is_a?(Date) 
          
          next_key = keys.sort.select {|i| i < key }.last
          next_key.nil? ? 0 : self[next_key]    
        end      
    end

    def before_validation_on_create
      self.created_by = User.current.public? ? nil : User.current.id
      self.revised_hours = self.estimated_hours
      true      
    end

    def before_validation_on_update
      self.revised_hours = self.revised_hours.to_i < 0 ? 0 : self.revised_hours.to_i
      true      
    end    
    
    def before_update
      if completed_at_changed? and completed?
        if percent_completed < 100
          progress_updates.update_or_create(Time.zone.today, 100)
        end
        status_updates.record! :completed, assigned
      elsif completed_at_changed? and not completed?
        status_updates.record! :re_opened, assigned
      end
      
      if assigned_to_changed?
        status_updates.record! :accepted, assigned
      end
      
      if revised_hours_changed?
        revisions.create :hours => revised_hours
      end
      true
    end

end
