module AdminAreaHelper

  def breadcrumbs(*tokens)    
    tokens.unshift link_to_admin_dashboard
    content_tag :h3, tokens.join(' / '), :id => 'breadcrumbs', :class => 'bottom-10'
  end

  def top_navigation_for(collection, label, new_path, *colspan, &block)
    additional_content = block_given? ? capture(&block) : ''    
    content = render :partial => 'admin/shared/thead_navigation', :locals => { 
      :collection => collection, 
      :label => label, 
      :new_path => new_path, 
      :colspan => colspan,
      :additional_content => additional_content }
    block_given? ? concat(content) : content
  end

  def bottom_navigation_for(collection, *colspan)
    render :partial => 'admin/shared/tfoot', 
      :locals => { :collection => collection, :colspan => colspan }    
  end
  
  def inactive_link(label)
    "<span class=\"inactive\">#{label}</span>"
  end  

end
