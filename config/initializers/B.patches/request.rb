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
    if parameters[:format].present?
      parameters[:format]
    elsif xhr?
      :js
    else
      :html
    end
  end
  
end