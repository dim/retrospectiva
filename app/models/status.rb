#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Status < ActiveRecord::Base
  include TicketPropertyGlobal    

  State = Struct.new(:id, :group, :name, :type)
  @@states = [
    State.new(1, N_('Open'), N_('All open'), :open),
    State.new(2, N_('In progress'), N_('All in progress'), :in_progress),
    State.new(3, N_('Resolved'), N_('All resolved'), :resolved)
  ].freeze
  cattr_reader :states

  Statement = Struct.new(:id, :name, :type)
  @@statements = [
    Statement.new(1, N_('Positive'), :positive),
    Statement.new(2, N_('Neutral'), :neutral),
    Statement.new(3, N_('Negative'), :negative)
  ].freeze  
  cattr_reader :statements

  validates_inclusion_of :state_id, :in => states.map(&:id)
  validates_inclusion_of :statement_id, :in => statements.map(&:id)

  class << self
    def state(id)
      states[id-1]
    end
  
    def statement(id)
      statements[id-1]
    end
  
    def label
      _('Status')
    end
  end
  
  def state
    self.class.state(state_id)
  end

  def statement
    self.class.statement(statement_id)
  end

end
