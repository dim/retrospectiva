class ApplicationController < ActionController::Base
  protect_from_forgery
  filter_parameter_logging :password
  
  before_filter :authenticate
  before_filter :store_back_to_path
  before_filter :set_locale
  before_filter :set_time_zone
  after_filter  :reset_request_cache!

  delegate :permitted?, :to => :'User.current'
  protected :permitted?
  
  helper_method :permitted?

  protected
    
    def store_back_to_path
      if User.current.public? && ( request.format.nil? || request.format.html? ) 
        session[:back_to] = "#{ActionController::Base.relative_url_root}#{request.path}"            
      end
      true 
    end
    
    def reset_request_cache!
      User.current = nil
      Project.current = nil
    end

    # Set locale
    def set_locale
      I18n.locale = RetroCM[:general][:basic][:locale]    
    end

    def set_time_zone
      Time.zone = User.current.time_zone
    end

    def cached_user_attribute(name, fallback = '')
      if User.current.public?
        cookie_cache[name.to_s] ||  fallback
      else
        User.current.send(name)
      end
    end

    def cache_user_attributes!(attributes)
      value = cookie_cache.merge(attributes.stringify_keys)
      cookies["retrospectiva__c"] = { 'value' => value.to_yaml, 'expires' => 6.months.from_now }
    end
    
    def cookie_cache
      value = YAML.load(Rack::Utils.unescape(cookies["retrospectiva__c"].to_s)) rescue nil
      value.is_a?(Hash) ? value : {}      
    end

    def load_channels(restriction = :present?, project = Project.current)
      Retrospectiva::Previewable.klasses.select(&restriction).group_by do |klass|
        channel = klass.previewable.channel(:project => project)
        User.current.has_access?(channel.path) ? channel : nil
      end.delete_if {|k, | k.nil? }
    end

    def rescue_action_in_public(exception) #:doc:
      status_code = response_code_for_rescue(exception)
      case status_code
      when :internal_server_error
        ExceptionNotifier.deliver_exception_notification(exception, self, request, {}) if ExceptionNotifier.exception_recipients.any?
      end
      render_optional_error_file(status_code)    
    end

    def failed_authorization!
      if User.current.public?
        case request.format
        when Mime::XML, Mime::RSS
          request_http_basic_authentication(RetroCM[:general][:basic][:site_name])
        else
          request.get? ? redirect_to(login_path) : super
        end
      else
        super
      end
    end

  private  

    def render_optional_error_file(status_code)
      status = interpret_status(status_code)
      path = "#{RAILS_ROOT}/app/views/rescue/#{status[0,3]}.html.erb"
      if File.exist?(path) and ( request.format.nil? or request.format.html? )
        render :file => path, :layout => 'application', :status => status
      else
        head status
      end
    end
    
end
