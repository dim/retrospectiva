class StoryStatusUpdate < StoryEvent

  def self.record!(content, creator)
    create do |record|
      record.content = content.to_s
      record.created_by = creator.id if creator
    end
  end

  def description    
    case content
    when 'accepted'   then _('Accepted')
    when 'completed'  then _('Completed')
    when 're_opened'  then _('Re-opened')
    else nil
    end
  end

  protected
  
    def before_validation_on_create
      self.created_by ||= User.current.public? ? nil : User.current.id
      true      
    end

end
