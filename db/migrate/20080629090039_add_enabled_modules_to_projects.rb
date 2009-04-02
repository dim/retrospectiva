class AddEnabledModulesToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :enabled_modules, :text

    select_all('SELECT id, disabled_modules FROM projects').each do |item|
      source = YAML.load(StringIO.new(item['disabled_modules'].to_s)) || next
      target = RetroAM.menu_items.map(&:name)      
      target.reject! do |name|
        source.include?(name.split('_').first)
      end if source.is_a?(Array)
      execute "UPDATE projects SET enabled_modules = #{quote(target.to_yaml)} WHERE id = #{item['id']}"
    end    
  end

  def self.down
    remove_column :projects, :enabled_modules, :text
  end
end
