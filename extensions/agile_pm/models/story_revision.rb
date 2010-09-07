class StoryRevision < StoryEvent
  validates_numericality_of :hours,
    :integer_only => true,
    :greater_or_equal => 0

  attr_accessible :hours, :creator
  
  def description
    _('Revision') + ': ' + _("%{count}h", :count => hours)
  end

end
