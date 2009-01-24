#--
# Copyright (C) 2007 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
module Admin::SetupHelper

  def setting_input(setting, f) 
    label = h(setting.label)
    unless setting.description.blank?
      alt_text = _('Toggle description for setting \'{{name}}\'', :name => label)
      image = image_tag('info.gif', :alt => alt_text, :title => alt_text)
      link = link_to_function image, visual_effect(:toggle_appear, "#{tag_id_for(setting)}_info", :duration => 0.25)
      label += ' ' + link
    end
    
    if setting.is_a?(RetroCM::BooleanSetting) 
      setting_tag(setting) + ' ' + f.click_choice(label, :for => tag_id_for(setting)) + '<br/>' 
    else
      f.label_tag(label, :for => tag_id_for(setting)) + ' ' + setting_tag(setting)
    end
  end

  def error_messages
    return '' if @errors.blank?

    title = "<h2>#{_('Configuration could not be saved')}</h2>"
    intro = "<p>#{_('There were problems')}:</p>"
    items = content_tag :ul, @errors.map {|key, message| "<li>#{key}: #{message}</li>" }
    
    "<div id=\"errorExplanation\" class=\"errorExplanation\">#{title}\n#{intro}\n#{items}</div>"
  end

  def setting_tag(setting)    
    tag = case setting
    when RetroCM::TextSetting
      text_setting_tag(setting)
    when RetroCM::StringSetting
      string_setting_tag(setting)
    when RetroCM::PasswordSetting
      password_setting_tag(setting)
    when RetroCM::IntegerSetting
      string_setting_tag(setting)
    when RetroCM::BooleanSetting
      boolean_setting_tag(setting)
    when RetroCM::SelectSetting
      select_setting_tag(setting)
    else
      value_for(setting)
    end
    wrap_error_tag(tag, @errors && @errors[setting.path]) 
  end

  def wrap_error_tag(html_tag, has_error)
    has_error ? field_error_proc.call(html_tag, self) : html_tag
  end
  
  def string_setting_tag(setting)
    value = value_for(setting).to_s
    text_field_tag(name_for(setting), h(value), options_for_string_setting_tag(setting))
  end

  def password_setting_tag(setting)
    value = value_for(setting).to_s
    password_field_tag(name_for(setting), h(value), options_for_string_setting_tag(setting))
  end

  def text_setting_tag(setting)    
    text_area_tag(name_for(setting), h(value_for(setting).to_s), options_for(setting).merge(:rows => 5, :cols => 120 ))
  end

  def boolean_setting_tag(setting)
    check_box_tag(name_for(setting), 1, value_for(setting), options_for(setting)) +
      hidden_field_tag(name_for(setting), 0, :id => tag_id_for(setting) + '_hidden')
  end

  def select_setting_tag(setting)
    options = options_for_select(setting.options, value_for(setting))
    select_tag(name_for(setting), options, options_for(setting))  
  end

  protected
    
    def options_for_string_setting_tag(setting)
      value = value_for(setting).to_s
      size = value.length > 20 ? value.length : 20
      options_for(setting).merge( :size => size > 50 ? 50 : size )    
    end

    def name_for(setting)
      group = setting.group
      section = group.section
      "#{prefix}[#{section.name}][#{group.name}][#{setting.name}]"
    end
  
    def tag_id_for(setting)
      group = setting.group
      section = group.section
      "#{prefix}_#{section.name}_#{group.name}_#{setting.name}"
    end
  
    def options_for(setting)
      {:id => tag_id_for(setting)}
    end
  
    def prefix
      'retro_cf'
    end
  
    def value_for(setting)
      group = setting.group
      section = group.section
      RetroCM[section.name][group.name][setting.name]
    end

end
