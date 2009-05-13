#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class TicketPropertyType < ActiveRecord::Base
  has_many :ticket_properties,
    :dependent => :destroy, 
    :order => 'ticket_properties.rank, ticket_properties.id'
  belongs_to :project

  validates_presence_of :project_id
  validates_uniqueness_of :name,
    :case_sensitive => false,
    :scope => :project_id,
    :allow_nil => true
  validates_format_of :name,
    :with => %r{^([A-Z][a-z]*)( [A-Z][a-z]*)*$},
    :allow_nil => true
  validates_length_of :name, :in => 2..20

  def class_name
    name.gsub(' ', '')
  end
 
  def label
    "#{project.name}: #{name}"
  end
 
  def global?
    false
  end

  def serialize_except
    [:project_id]
  end

  protected

    def validate
      errors.add :name, :taken if ['Status', 'Priority'].include?(name)
      errors.empty?
    end
 
end
