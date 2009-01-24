class UpdateChangedAttributesInAllTicketChanges < ActiveRecord::Migration
  def self.up
    TicketChange.find(:all).each do |change|
      unless change.changes.blank?
        change.changes.keys.each do |key|
          if ['Author', 'Email'].include?(key.humanize)
            change.changes.delete(key)
          elsif key.humanize != key
            change.changes[key.humanize] = change.changes.delete(key)
          end
        end
        change.save
      end
    end    
  end

  def self.down
    TicketChange.find(:all).each do |change|
      unless change.changes.blank?
        change.changes.keys.each do |key|
          fkey = key.dup.gsub(%r{ }, '_').downcase + '_id'
          if fkey != key
            change.changes[fkey] = change.changes.delete(key)
          end
        end
        change.save
      end
    end
  end
  
end
