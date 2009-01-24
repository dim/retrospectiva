module Admin::ProjectsHelper

  def enabled_modules_selection(f)
    RetroAM.sorted_menu_items(@project.enabled_modules).map do |item|
      checked = @project.enabled_modules.include?(item.name) rescue false        
      content = check_box_tag("project[enabled_modules][]", item.name, checked, :id => "project_enabled_modules_#{item.name}") 
      "<li id=\"enabled_module_#{item.name}\">#{content + f.click_choice(item.label)}</li>"
    end.join("\n")
  end

end
