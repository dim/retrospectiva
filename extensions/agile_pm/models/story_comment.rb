class StoryComment < StoryEvent
  validates_length_of :content, :in => 3..4000

  attr_accessible :content

  def title
    _('Comment')
  end

  def description
    content
  end

end
