module AssociationProxies::SprintStories
  REMAINING_HOURS_PROC = lambda {|s| s.remaining_hours(Time.zone.today) }    
    
  def active_count
    @active_count ||= proxy_target.select(&:active?).size
  end

  def completed_count
    @completed_count ||= proxy_target.select(&:completed?).size
  end

  def pending_count
    @pending_count ||= proxy_target.select(&:pending?).size
  end

  def completed_ratio
    size.zero? ? 0 : completed_count / size.to_f
  end

  def active_ratio
    size.zero? ? 0 : active_count / size.to_f
  end

  def total_hours
    @total_hours ||= proxy_target.map(&:revised_hours).sum.round    
  end

  def remaining_hours
    @remaining_hours ||= proxy_target.map(&REMAINING_HOURS_PROC).sum.round
  end

  def active_hours
    @active_hours ||= proxy_target.select(&:active?).map(&REMAINING_HOURS_PROC).sum.round
  end

  def pending_hours
    @pending_hours ||= proxy_target.select(&:pending?).map(&REMAINING_HOURS_PROC).sum.round
  end

  def completed_hours
    total_hours - remaining_hours
  end
  
  def by_status
    sort_by do |story|
      [story.completed? ? story.completed_at.to_i : 10 ** 12, story.created_at]
    end
  end
end