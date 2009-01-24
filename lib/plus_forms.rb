module PlusForms
  
  module Helper
    [:form_for, :fields_for, :form_remote_for, :remote_form_for].each do |meth|
      src = <<-end_src
        def plus_#{meth}(object_name, *args, &proc)
          options = args.last.is_a?(Hash) ? args.pop : {}
          options.update(:builder => FormBuilder)
          options[:html] ||= {}
          options[:html][:class] ||= ''
          options[:html][:class] = (['plus_form'] + options[:html][:class].split(' ')).join(' ')
          #{meth}(object_name, *(args << options), &proc)
        end
      end_src
      module_eval src, __FILE__, __LINE__
    end
  end

  class FormBuilder < ActionView::Helpers::FormBuilder #:nodoc:  
    cattr_accessor :font_styles
    self.font_styles = {
      :info => :h2,
      :section => :h3      
    }
    
    def fields_for(object_name, *args, &proc)
      @template.plus_fields_for(object_name, *args, &proc)
    end

    def fieldset(*args, &block)
      content = @template.capture(&block)      
      @template.concat(fieldset_tag(content, *args))
    end
    
    def fieldset_tag(text, *args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      instruction = options.delete(:instruct)
      
      options[:class] = args.flatten.map(&:to_s).join(' ')      
      if instruction
        text = instruct(instruction) + text
      end
      @template.content_tag(:fieldset, text, options)
    end
          
    def info(title, &block)      
      content = @template.content_tag font_styles[:info], title
      if block_given?
        content += @template.capture(&block) 
        @template.concat(fieldset_tag(content, :info))
      else
        fieldset_tag content, :info
      end
    end

    def section(title, &block)      
      content = @template.content_tag font_styles[:section], title
      if block_given?
        content += @template.capture(&block) 
        @template.concat(fieldset_tag(content, :section))
      else
        fieldset_tag content, :section
      end
    end


    def label(method, text = nil, options = {})
      if text && options.delete(:required)
        text += ' <span class="required">*</span>'
      end
      super(method, text, options)
    end

    def explain(method, text, options = {})
      label method, text, options.merge(:class => 'explain')
    end

    def label_tag(text, options = {})
      label(nil, text, options)
    end

    def instruct(text, options = {})
      options[:tag] ||= :p
      @template.content_tag options[:tag], text, :class => 'instruct'
    end


    def radio_buttons(method, choices, options = {})
      return '' if choices.blank?

      content = choices.map do |label, value|
        @template.radio_button(object_name, method, value) + ' ' + 
          click_choice(label, :for => [object_name, method, value])
      end.join(options[:inline] ? ' ' : '<br/>')      
      wrap_field(options[:wrap], content, options[:wrap_options])
    end
    
    def check_boxes(method, choices, options = {})
      return '' if choices.blank?
      
      columns = options[:cols] || 1
      per_col = options[:per_col] || (choices.size.to_f / columns.to_f).ceil
      
      choices.in_groups_of(per_col).map do |group|
        name = "#{object_name}[#{method}][]"
        content = group.compact.map do |label, value|
          element_id = "#{object_name}_#{method}_#{value}"
          checked = object.send(method).include?(value) rescue false
          @template.check_box_tag(name, value, checked, :id => element_id) + 
            click_choice(label, :for => [object_name, method, value])
        end.join(options[:inline] ? ' ' : '<br/>')
        content += @template.hidden_field_tag name, nil, :id => "#{object_name}_#{method}_hidden"
        wrap_field(options[:wrap], content, options[:wrap_options])
      end.join("\n")
    end

    def collection_check_boxes(method, collection, id_method = :id, name_method = :name, options = {})
      choices = collection.map do |i| 
        [@template.send(:h, i.send(name_method)), i.send(id_method)]
      end
      check_boxes method, choices, options
    end

    def click_choice(content, options = {})
      options[:for] = options[:for].map(&:to_s).join('_') if options[:for].is_a?(Array)
      options[:class] ||= 'choice'
      label_tag content, options
    end

    ['text_field', 'text_area', 'password_field', 'hidden_field', 'file_field', 'date_select'].each do |selector|
      src = <<-end_src
        def #{selector}(method, options = {})
          text = options.delete(:explain)
          wrap = options.delete(:wrap)
          wopt = options.delete(:wrap_options)
          content = super(method, options) + 
            (text.blank? ? '' : explain(method, text))
          wrap_field(wrap, content, wopt)
        end
      end_src
      class_eval src, __FILE__, __LINE__
    end

    def select(method, choices, options = {}, html_options = {})
      text = options.delete(:explain)
      wrap = options.delete(:wrap)
      wopt = options.delete(:wrap_options)
      content = super(method, choices, options, html_options) + 
        (text.blank? ? '' : explain(method, text))
      wrap_field(wrap, content, wopt)
    end

    def collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
      text = options.delete(:explain)
      wrap = options.delete(:wrap)
      wopt = options.delete(:wrap_options)
      content = super(method, collection, value_method, text_method, options, html_options) + 
        (text.blank? ? '' : explain(method, text))
      wrap_field(wrap, content, wopt)
    end

    def related_collection_select(method, parent_element, collection, value_method, text_method, reference_method, options = {}, html_options = {})
      text = options.delete(:explain)
      wrap = options.delete(:wrap)
      wopt = options.delete(:wrap_options)
      content = @template.related_collection_select(@object_name, method, parent_element, collection, value_method, text_method, reference_method, options, html_options) + 
        (text.blank? ? '' : explain(method, text))
      wrap_field(wrap, content, wopt)
    end

    def country_select(method, priority_countries = nil, options = {}, html_options = {})
      text = options.delete(:explain)
      wrap = options.delete(:wrap)
      wopt = options.delete(:wrap_options)
      content = super(method, priority_zones, options, html_options) + 
        (text.blank? ? '' : explain(method, text))
      wrap_field(wrap, content, wopt)
    end

    def time_zone_select(method, priority_zones = nil, options = {}, html_options = {})
      text = options.delete(:explain)
      wrap = options.delete(:wrap)
      wopt = options.delete(:wrap_options)
      content = super(method, priority_zones, options, html_options) + 
        (text.blank? ? '' : explain(method, text))
      wrap_field(wrap, content, wopt)
    end
    
    def wrap_field(tag, content, options = {})
      tag = :div if tag.nil?
      tag ? @template.content_tag(tag, content, options) : content
    end
    protected :wrap_field
  end

end  


ActionView::Helpers::InstanceTag.class_eval do
  def to_label_tag(text = nil, options = {})
    options.stringify_keys!
    name_and_id = options.dup
    add_default_name_and_id(name_and_id)
    options["for"] ||= name_and_id["id"]
    content = (text.blank? ? nil : text.to_s) || method_name.humanize
    content_tag("label", content, options)
  end
end
