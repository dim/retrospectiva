#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Repository < ActiveRecord::Base
  class RepositoryError < StandardError; end
  class RevisionNotFound < RepositoryError; end
  class InvalidRevision < RepositoryError; end

  has_many :changes, :through => :changesets
  has_many :changesets, :dependent => :destroy
  has_many :projects, :dependent => :nullify  

  class << self    
    def types
      Repository::Abstract.subclasses.map do |klass|        
        klass.name.demodulize
      end.sort
    end
    
    def klass(type)
      const_get(type.to_s.classify.to_sym) rescue nil
    end
    alias_method :[], :klass    
  end

  validates_presence_of :name, :path
  validates_uniqueness_of :name, :case_sensitive => false
  validates_uniqueness_of :path
  validates_inclusion_of :kind, :in => Repository.types
  
  def diff_scanner
    self.class.const_get(:DiffScanner)
  end

  def kind
    self[:type] ? self[:type].to_s.demodulize : nil
  end 
  
  def kind=(value)
  end  
end
