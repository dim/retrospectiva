#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Milestone < ActiveRecord::Base
  has_many :tickets, :include => [:status], :dependent => :nullify 
  belongs_to :project

  validates_presence_of :name, :project_id, :started_on
  validates_uniqueness_of :name, :scope => :project_id
  validates_length_of :info, :maximum => 50000, :allow_blank => true

  retro_previewable do |r|
    r.channel do |c, options|
      project = options[:project] || Project.current
      c.name = 'milestones'
      c.title = _('Milestones')
      c.description = _('Milestones for {{project}}', :project => project.name)
      c.link = c.route(:project_milestones_url, project)
    end
    r.item do |i, milestone, options|
      project = options[:project] || Project.current
      i.title = _('Milestone') + ': ' + milestone.name
      i.description = milestone.info
      i.date = milestone.updated_at.to_time
      i.link = i.guid = i.route(:project_milestones_url, project)
    end
  end
  
  class << self

    def per_page
      5
    end

    def default_order
      'CASE WHEN milestones.due IS NULL THEN 1 ELSE 0 END, milestones.due ASC, milestones.finished_on DESC'
    end

    def searchable_column_names
      [ 'milestones.name', 'milestones.info' ]
    end    
    
    def full_text_search(query)
      filter = Retro::Search::exclusive query, *searchable_column_names
      feedable.find :all, 
        :conditions => filter, 
        :limit => 100,
        :order => default_order
    end

  end

  named_scope :feedable, :limit => 10, :order => 'milestones.updated_at DESC'    

  named_scope :active_on, lambda { |date| { 
    :conditions => ['( milestones.finished_on IS NULL OR milestones.finished_on >= ? )', date] 
  }}    
  
  def open_tickets
    ticket_count_by_state(1)
  end
  
  def closed_tickets
    ticket_count_by_state(3)
  end
  
  def total_tickets
    ticket_count_by_state(1, 2, 3)
  end
    
  def percent_completed
    total_tickets.zero? ? 0 : (closed_tickets.to_f / total_tickets.to_f * 100).round
  end
  
  def completed?
    finished_on.present?
  end

  def started_on
    read_attribute(:started_on) || write_attribute(:started_on, Date.today)
  end
  
  private
 
    def ticket_count_by_state(*state_ids)
      if tickets.loaded?
        tickets.select {|i| state_ids.include?(i.status.state_id) }.size
      else
        tickets.count(:all, :conditions => ['statuses.state_id IN (?)', state_ids])
      end
    end

end
