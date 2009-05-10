class RetrospectivaExtensionAssetsController < ActionController::Base
  caches_page :show
  
  before_filter :load_extension
  before_filter :load_path

  def show
    local_tokens = [ params[:asset_type],  @path ].compact.flatten
    full_path = @extension.public_path(*local_tokens)    
    
    if File.exist?(full_path)
      send_file full_path, :disposition => 'inline', :stream => false, :type => mime_type_for(@path)
    else
      failed_to_find_asset
    end
  end

  protected
  
    def load_extension
      @extension = RetroEM::Extension.load(params[:extension].to_s)
      failed_to_find_asset unless @extension 
    end

    def load_path
      @path = params[:path].join('/')
      failed_to_find_asset if @path.blank? or @path.include?('..')
    end
    
    def failed_to_find_asset
      render :nothing => true, :status => 404      
    end
  
  private
  
    def mime_type_for(path)
      extension = File.extname(path).gsub(/\W/, '').downcase
      case extension
      when 'js'
        'text/javascript'
      when 'css'
        'text/css'
      when 'gif'
        'image/gif'
      when 'jpg', 'jpeg'
        'image/jpeg'
      when 'png'
        'image/png'
      when 'swf'
        'application/x-shockwave-flash'
      else
        'application/binary'
      end
    end

end


