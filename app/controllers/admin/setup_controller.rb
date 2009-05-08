#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::SetupController < AdminAreaController
  before_filter :validate_site_url
  before_filter :load_configuration, :only => :index
  verify :params => :retro_cf, :only => :save
  
  def index    
    respond_to do |format|
      format.html
      format.xml { render :xml => @sections.to_xml(:root => 'sections') }      
    end    
  end

  def save
    respond_to do |format|
      if RetroCM.update(params[:retro_cf])
        flash[:notice] = _('Settings were successfully saved.')
        format.html { redirect_to(admin_setup_path) }
        format.xml  { head :ok }              
      else
        load_configuration        
        format.html { render :action => 'index' }
        format.xml  { render :xml => @errors, :status => :unprocessable_entity }              
      end
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

    def load_configuration
      @configuration = RetroCM.configuration
      @sections = RetroCM.sections     
    end
    
end
