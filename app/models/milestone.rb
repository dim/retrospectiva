#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Milestone < ActiveRecord::Base
  has_many :tickets, :include => [:status], :dependent => :nullify do
    
    def count_by_state(*state_ids)
      if loaded?
        target.select {|i| state_ids.include?(i.status.state_id) }.size
      else
        count(:all, :conditions => ['statuses.state_id IN (?)', state_ids])
      end      
    end
    
  end
  belongs_to :project

  validates_presence_of :name, :project_id, :started_on
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :project_id
  validates_length_of :info, :maximum => 50000, :allow_blank => true

  retro_previewable do |r|
    r.channel do |c, options|
      project = options[:project] || Project.current
      c.name = 'milestones'
      c.title = _('Milestones')
      c.description = _('Milestones for %{project}', :project => project.name)
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
      'CASE WHEN milestones.due IS NULL THEN 1 ELSE 0 END, milestones.due ASC, milestones.finished_on DESC, milestones.started_on ASC'
    end

    def reverse_order
      'CASE WHEN milestones.due IS NULL THEN 1 ELSE 0 END, milestones.due DESC, milestones.finished_on ASC, milestones.started_on DESC'
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
  
  named_scope :in_default_order,
    :order => default_order

  named_scope :in_reverse_order,
    :order => reverse_order
  
  def ticket_counts
    @tickets_counts ||= Status.states.inject({}) do |result, state|
      result.merge state.type => tickets.count_by_state(state.id)
    end.with_indifferent_access
  end

  def progress_percentages
    @progress_percentages ||= calculate_percentages
  end
  
  def total_tickets
    @total_tickets ||= tickets.count_by_state(1, 2, 3)
  end
    
  def completed?
    finished_on.present?
  end

  def started_on
    read_attribute(:started_on) || write_attribute(:started_on, Date.today)
  end
  
  def serialize_only
    [:id, :name, :info, :started_on, :finished_on, :due]
  end
  
  private
    
    def calculate_percentages
      result = Status.states.reverse.inject({}) do |result, state|
        result.merge state.type => ( total_tickets.zero? ? 0 : (ticket_counts[state.type] / total_tickets.to_f * 100).round )
      end.with_indifferent_access
      correct_percentages(result)
    end

    def correct_percentages(percentages)
      sum_of_all = percentages.values.sum
      case sum_of_all
      when 0..99
        percentages['open'] += (100 - sum_of_all)
      when 101        
        key = ( percentages.key?('open') and percentages['open'] > 0 ? 'open' : percentages.sort_by(&:last).last.first )        
        percentages[key] -= 1
      end
      percentages        
    end

end
