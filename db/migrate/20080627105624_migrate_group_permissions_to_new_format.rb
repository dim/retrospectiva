class MigrateGroupPermissionsToNewFormat < ActiveRecord::Migration
  def self.up
    select_all('SELECT id, permissions FROM groups').each do |item|
      target = {}
      source = item['permissions'].present? ? YAML.load(item['permissions']) : []
      source.each do |name|
        case name
        when 'create_and_work_on_tickets'
          target['tickets'] ||= []
          target['tickets'] << 'create'
          target['tickets'] << 'update'
        when 'comment_blogs'
          target['blog_posts'] ||= []
          target['blog_posts'] << 'comment'
        when 'edit_blog'
          target['blog_posts'] ||= []
          target['blog_posts'] << 'update'
        when 'subscribe_to_tickets'
          target['tickets'] ||= []
          target['tickets'] << 'watch'
        when 'view_blog'
          target['blog_posts'] ||= []
          target['blog_posts'] << 'view'
        else
          permission, resource = name.split('_').map(&:to_s)          
          resource ||= 'content'
          permission = 'update' if permission == 'edit'
          target[resource] ||= []
          target[resource] << permission
        end        
      end
      if source.is_a?(Array)
        execute "UPDATE groups SET permissions = #{quote(target.to_yaml)} WHERE id = #{item['id']}"
      end
    end
  end

  def self.down
  end
end
