class ProjectsController < ApplicationController  
  enable_private_rss :only => [:index, :show]

  before_filter :find_projects
 
  def index
    if User.current.public? && @projects.empty?
      flash.keep
      redirect_to login_path
    elsif request.format.rss? 
      render_index_rss
    elsif @projects.size == 1
      flash.keep
      redirect_to @projects.first.path_to_first_menu_item      
    end    
  end
  
  def show
    @project = @projects.find(params[:id])    
    if @project.blank? 
      redirect_to projects_path
    elsif request.format.rss?
      render_show_rss(@project)
    else      
      redirect_to @project.path_to_first_menu_item
    end
  end  

  protected

    def find_projects
      @projects = User.current.active_projects
      @projects.reject! do |project|
        project_has_no_accessible_menu_items?(project)
      end
    end

    def project_has_no_accessible_menu_items?(project)
      project.enabled_menu_items.find do |item|
        path = item.path(self, project)

        if User.current.has_access?(path)
          project.path_to_first_menu_item = path
          true
        else 
          nil
        end
      end.nil?
    end

    def render_index_rss
      @records = User.current.active_projects.inject([]) do |result, project|                
        find_feedable_records(project).each do |record|
          result << [record, project]
        end        
        result
      end.sort do |(ra, pa), (rb, pb)|
        rb.previewable(:project => pb).date <=> ra.previewable(:project => pa).date
      end.first(10)

      render_rss _('All Projects'), _('All news for all projects'), projects_url do |items|
        @records.each do |record, project|
          record.to_rss(items.new_item, :project => project)
        end
      end
    end

    def render_show_rss(project)
      render_rss project.name, 
        _('All news for {{project}}', :project => project.name), 
        project_url(project) do |items|

        find_feedable_records(project).each do |record|
          record.to_rss(items.new_item, :project => project)
        end
      end
    end

  private
  
    def find_feedable_records(project, limit = 10)
      load_channels(:feedable?, project).values.flatten.map do |klass|
        project.send(klass.table_name).feedable
      end.flatten.sort do |a, b| 
        b.previewable(:project => project).date <=> a.previewable(:project => project).date
      end.first(limit)
    end

    def render_rss(title, description, link, &block)
      content = RSS::Maker.make('2.0') do |rss|
        rss.channel.title = title 
        rss.channel.description = description
        rss.channel.link = link        
        yield(rss.items)
        rss.items.do_sort = true
      end
      render :xml => content.to_s, :content_type => 'application/rss+xml'      
    end

end
