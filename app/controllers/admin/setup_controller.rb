#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::SetupController < AdminAreaController
  before_filter :validate_site_url
  verify :params => :retro_cf, :only => :save
  
  def index
    @sections = RetroCM.sections
  end

  def save
    if RetroCM.update(params[:retro_cf])
      flash[:notice] = _('Settings were successfully saved.')
      redirect_to(admin_setup_path)
    else
      @errors = RetroCM.errors
      index
      render :action => 'index'      
    end
  end

  protected
  
    def validate_site_url
      url_setting = RetroCM[:general][:basic].setting(:site_url)
      if url_setting.default? && request.port_string.blank?
        RetroCM[:general][:basic][:site_url] = request.protocol + request.host_with_port
      end
      true
    end
    
end
