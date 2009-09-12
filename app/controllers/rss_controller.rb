class RssController < ApplicationController
  before_filter :load_project_map
    
  def index
    @projects = @project_map.keys
  end
  
  protected

    def load_project_map
      @project_map = User.current.projects.active.inject(ActiveSupport::OrderedHash.new) do |project_map, project|         
        project_map[project] = load_channels(:feedable?, project) 
        project_map       
      end.delete_if {|k, v| v.empty? }
    end
  
end
