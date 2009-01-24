class TicketReport < ActiveRecord::Base
  belongs_to :project

  serialize :filter_options, Hash

  validates_presence_of :name, :project_id
  validates_uniqueness_of :name, :scope => :project_id
  validates_numericality_of :time_interval, 
    :integer_only => true,
    :greater_than_or_equal => 1.day,
    :allow_nil => true
    
  VALID_UNITS = ['days', 'weeks', 'months']
    
  def time_interval=(value = nil)    
    seconds = if value.is_a?(Integer)
      value
    elsif value.is_a?(Hash) && value[:count].to_i > 0 && VALID_UNITS.include?(value[:units])
      value[:count].to_i.send(value[:units])
    else
      nil
    end
    write_attribute(:time_interval, seconds)    
  end

  def filter_options
    value = read_attribute(:filter_options)
    value.is_a?(Hash) ? value : {}
  end
  
  def since
    time_interval.to_i < 1 ? nil : Time.zone.now - time_interval
  end

  def user_specific?
    filter_options.key?(:my_tickets)  
  end

  protected
  
    def validate      
      errors.add :filter_options, :blank if filter_options.blank?
      errors.empty?
    end
  
end
