module FlashHelper

  def render_flash_messages
    return '' unless flash[:error] || flash[:notice] || flash[:warning]

    render(:partial => 'layouts/flash_messages') + 
      javascript_tag( 
        visual_effect(:appear, 'flash_box', :duration => 0.5, :to => 0.7, :queue => {:position => :end, :scope => :folder}) + 
        visual_effect(:fade, 'flash_box', :duration => 0.5, :delay => 8, :from => 0.7, :queue => {:position => :end, :scope => :folder}))        
  end

end