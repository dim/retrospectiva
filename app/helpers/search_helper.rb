module SearchHelper

  def channel_checkboxes(f)
    boxes = @channels_index.keys.sort_by(&:title).map do |channel|      
      box = check_box_tag channel.name, 1, params[channel.name] == '1',
        :id => "channel_#{channel.name}",
        :onclick => "if (this.checked) $('channel_all').checked = false;"
      label = f.click_choice channel.title, :for => "channel_#{channel.name}"       
      box + label  
    end

    box = check_box_tag :all, 1, params[:all] == '1' || !params.key?(:q), :id => 'channel_all'
    label = f.click_choice(_('All'), :for => 'channel_all')
    
    boxes.unshift box + label

    boxes.in_groups_of(8).map do |row|
      row.join(' ')
    end.join("<br/>")
  end
  
  def highlight_matches(content, string)
    pattern = Retro::Search.new(string).tokens.reject(&:exclude?).map do |token|
      "(?:#{Regexp.escape(token)})"
    end.join('|')
    
    blocks = content.split(/#{pattern}/im)              

    result = []
    
    content.scan(/#{pattern}/im).each_with_index do |match, i|
      before = blocks[i] || ''
      after =  blocks[i+1] || ''
          
      if before.size > 120
        result << '... ' + before.last(120).lstrip
      elsif i.zero?
        result << before
      end

      result << "<span class=\"highlight\">#{match}</span>"
                
      if after.size > 120
        result << after.first(120).rstrip + ' ...<br/>'
      else
        result << after
      end
    end

    result.empty? ? content : result.join    
  end
  
end
