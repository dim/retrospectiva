#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Change < ActiveRecord::Base
  extend ActiveSupport::Memoizable

  belongs_to :changeset
  belongs_to :repository

  validates_inclusion_of :name, :in => ['CP', 'MV', 'A', 'D', 'M']
  validates_presence_of :revision  

  def previous_revision
    return '-' unless repository.active?
    
    repository.history(path, revision).reject do |hrev|
      hrev == revision
    end.first.to_s
  end
  memoize :previous_revision

  def unified_diff(max_size = 512.kilobyte)
    if @unified_diff.nil? && diffable?
      node = repository.node(path, revision)
      if node.size < max_size
        @unified_diff = repository.unified_diff(path, previous_revision, revision)
      end
    end
    @unified_diff ||= ''
  end
  
  def diffable?
    repository.active? && name == 'M'
  end

  protected
  
    def before_validation
      if changeset
        self.repository_id = changeset.repository_id
        self.revision = changeset.revision
      end
      true
    end
  
end
