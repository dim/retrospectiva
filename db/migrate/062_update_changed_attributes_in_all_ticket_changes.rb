class UpdateChangedAttributesInAllTicketChanges < ActiveRecord::Migration
  def self.up
    select_all("SELECT * FROM ticket_changes").each do |change|
      changes = YAML.load(change['changes'])
      next if changes.blank?

      changes.keys.each do |key|
        if ['Author', 'Email'].include?(key.humanize)
          changes.delete(key)
        elsif key.humanize != key
          changes[key.humanize] = changes.delete(key)
        end
      end
      update "UPDATE ticket_changes SET changes = #{quote(changes.to_yaml)} WHERE id = #{change['id']}"
    end rescue true
  end

  def self.down
    select_all("SELECT * FROM ticket_changes").each do |change|
      changes = YAML.load(change['changes'])
      next if changes.blank?

      changes.keys.each do |key|
        fkey = key.dup.gsub(%r{ }, '_').downcase + '_id'
        if fkey != key
          changes[fkey] = changes.delete(key)
        end
      end
      update "UPDATE ticket_changes SET changes = #{quote(changes.to_yaml)} WHERE id = #{change['id']}"
    end rescue true
  end
  
end
