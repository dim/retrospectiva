#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
module Admin::SetupHelper

  def setting_input(setting, f) 
    label = h(setting.label)
    unless setting.description.blank?
      alt_text = _("Toggle description for setting '%{name}'", :name => label)
      image = image_tag('info.gif', :alt => alt_text, :title => alt_text)
      link = link_to_function image, visual_effect(:toggle_appear, "#{tag_id_for(setting)}_info", :duration => 0.25)
      label += ' ' + link
    end
    
    f.label_tag(label, :for => tag_id_for(setting)) + ' ' + setting_tag(setting)
  end

  def setting_tag(setting)    
    case setting
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
  end

  def string_setting_tag(setting, tag_method = :text_field_tag, options = {})
    send tag_method, name_for(setting), value_for(setting).to_s, options_for_string_setting_tag(setting).merge(options)
  end

  def password_setting_tag(setting)
    string_setting_tag setting, :password_field_tag
  end

  def text_setting_tag(setting)    
    string_setting_tag setting, :text_area_tag, :rows => 5, :cols => 120
  end

  def boolean_setting_tag(setting)    
    choices = options_for_select([[_('Yes'), 1], [_('No'), 0]], value_for(setting) ? 1 : 0)
    select_tag name_for(setting), choices, options_for(setting)  
  end

  def select_setting_tag(setting)
    choices = options_for_select(setting.options, value_for(setting))
    select_tag name_for(setting), choices, options_for(setting)  
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
