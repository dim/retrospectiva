#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Change < ActiveRecord::Base
  extend ActiveSupport::Memoizable

  cattr_accessor :maximum_diff_size
  self.maximum_diff_size = 512.kilobyte

  belongs_to :changeset
  belongs_to :repository

  validates_inclusion_of :name, :in => ['CP', 'MV', 'A', 'D', 'M']
  validates_presence_of :revision  

  def previous_revision
    return '-' unless repository.active?    
    repository.history(path, revision, 2).last.to_s
  end
  memoize :previous_revision

  def unified_diff    
    begin
      node = repository.node(path, revision)
      if node.size < self.class.maximum_diff_size
        @unified_diff = repository.unified_diff(path, previous_revision, revision)
      end
    rescue Repository::Abstract::Node::NodeError
    end if @unified_diff.nil? && diffable?
    @unified_diff ||= ''
  end
  
  def unified_diff?
    unified_diff.present?
  end
  
  def diffable?
    repository.active? && name == 'M'
  end
  
  def serialize_only
    [:id, :path, :from_path, :from_revision, :name]
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
