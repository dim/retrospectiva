ActionView::Base.field_error_proc = lambda {|html_tag, instance| "<span class=\"fieldWithErrors\">#{html_tag}</span>" }
