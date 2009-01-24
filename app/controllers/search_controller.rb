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

  before_filter :load_channels
  
  def index
    @results = params[:q].blank? ? [] : query_results
  end
  
  protected
    
    def load_channels
      @channels_index = Retrospectiva::Previewable.klasses.select(&:searchable?).group_by do |klass|
        channel = klass.previewable.channel
        User.current.has_access?(channel.path) ? channel : nil
      end.delete_if {|k,| k.nil? }
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
