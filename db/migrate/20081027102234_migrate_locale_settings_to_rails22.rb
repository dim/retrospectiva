class MigrateLocaleSettingsToRails22 < ActiveRecord::Migration
  def self.up
    records = select_all "SELECT id, locale FROM projects WHERE locale IS NOT NULL"
    records.each do |hash|
      locale = RetroI18n.normalize_code(hash['locale'])
      next if hash['locale'] == locale
      execute "UPDATE projects SET locale = #{quote(locale)} WHERE id = #{hash['id']}"
    end
  end

  def self.down
    records = select_all "SELECT id, locale FROM projects WHERE locale IS NOT NULL"
    records.each do |hash|
      locale = hash['locale'].split(/[^a-z]/i).join('_')
      next if hash['locale'] == locale
      execute "UPDATE projects SET locale = #{quote(locale)} WHERE id = #{hash['id']}"
    end
  end
end
