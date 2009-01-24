module Admin::GroupsHelper
   
  def format_permissions(group, resource)
    resource.values.sort.map do |permission|        
      content_tag :span, _(permission.label), 
        :class => (group.permitted?(resource.name, permission.name) ? 'loud' : 'quieter')
    end.join('<br/>')
  end
  
  def check_boxes_for_permissions(resource, f)    
    resource.values.sort.map do |permission|
      element_id = "group_permissions_#{resource.name}_#{permission.name}"
      checked = @group.permitted?(resource.name, permission.name)
      
      check_box_tag("group[permissions][#{resource.name}][]", permission.name, checked, :id => element_id) + 
        f.click_choice(_(permission.label), :for => element_id)
    end.join(', ')
  end
  
  def project_selection(f)
    f.check_boxes :project_ids, @projects.map{|i| [h(i.name), i.id]}, :cols => 4
  end

end
