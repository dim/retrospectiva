class SearchController < ProjectAreaController
  menu_item :search do |i|
    i.label = N_('Search')
    i.path = lambda do |project| 
      project_search_path(project)
    end
    i.rank = 600
  end
  require_permissions :content, 
    :search => ['index']

  def index
    @channels_index = load_channels(:searchable?)
    @results = params[:q].blank? ? [] : query_results
  end
    
  private
  
    def query_results
      @channels_index.values.flatten.uniq.inject([]) do |result, klass|        
        if params[:all] == '1' || params[klass.previewable.channel.name] == '1'
          result += Project.current.send(klass.table_name).full_text_search(params[:q])
        end
        result
      end.sort{|a,b| b.previewable.date <=> a.previewable.date }
    end
    
end
