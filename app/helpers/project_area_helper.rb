module ProjectAreaHelper
  
  def main_navigation
    RetroAM.sorted_menu_items(Project.current.enabled_modules).map do |item|
      path = item.path(self, Project.current)
      
      next unless User.current.has_access?(path)
      link_to _(item.label), path, 
        :class => (item.active?(controller.class.name, controller.action_name) ? 'active' : nil)      
    end.compact.map do |link|
      "<li>#{link}</li>"
    end.join('')
  end

end
