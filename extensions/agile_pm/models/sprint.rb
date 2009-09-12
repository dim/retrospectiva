class Sprint < ActiveRecord::Base
  extend ActiveSupport::Memoizable
  
  belongs_to :milestone
  has_many :goals, :dependent => :nullify
  has_many :stories, :dependent => :destroy, :extend => AssociationProxies::SprintStories
  has_many :progress_updates, :through => :stories

  validates_presence_of :title, :starts_on, :finishes_on
  validates_uniqueness_of :title, :scope => :milestone_id
  validates_association_of :milestone
  
  attr_accessible :title, :starts_on, :finishes_on

  named_scope :in_order_of_relevance, lambda {{
    :order => relevant_order
  }}

  def self.relevant_order
    today = Time.zone.today
    %Q(
      CASE WHEN #{quoted_table_name}.finishes_on < #{connection.quote(today)} THEN 1 ELSE 0 END, 
      CASE WHEN #{quoted_table_name}.starts_on > #{connection.quote(today)} THEN 1 ELSE 0 END, 
      #{quoted_table_name}.starts_on DESC, 
      #{quoted_table_name}.finishes_on
    ).squish    
  end

  def remaining_hours(date)
    stories.map {|s| s.remaining_hours(date) }.sum
  end

  def each_day(&block)
    (starts_on..finishes_on).each(&block)
  end

  def time_line
    result = ActiveSupport::OrderedHash.new
    result[nil] = remaining_hours(starts_on - 1).round    
    each_day do |date|
      result[date] = remaining_hours(date).round
    end
    result
  end
  memoize :time_line

  protected
  
    def validate
      if starts_on and finishes_on and finishes_on < starts_on 
        errors.add :finishes_on, :before_starts_on
      end
      errors.empty?
    end
  
end
