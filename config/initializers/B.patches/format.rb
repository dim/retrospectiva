ActionController::Request.class_eval do

  def format
    @format ||=
      if parameters[:format].present?
        Mime::Type.lookup_by_extension(parameters[:format])
      elsif ActionController::Base.use_accept_header
        accepts.first
      elsif xhr?
        Mime::Type.lookup_by_extension("js")
      else
        Mime::Type.lookup_by_extension("html")
      end
  end

  def template_format
    parameter_format = parameters[:format]

    if parameter_format.present?
      parameter_format
    elsif xhr?
      :js
    else
      :html
    end
  end

end
