#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::TasksController < AdminAreaController
  verify :params => :tasks, :only => :save

  def index
    @tasks = Retrospectiva::TaskManager::Parser.new.tasks
    respond_to do |format|
      format.html
      format.xml { render :xml => @tasks.to_xml(:root => 'tasks', :except => ['id']) }
    end
  end
  
  def save
    params[:tasks].each do |name, interval|
      seconds = TimeInterval.in_seconds(interval[:count], interval[:units]) rescue 0
      Retrospectiva::TaskManager::Task.create_or_update(name, seconds)
    end if params[:tasks].is_a?(Hash)
    flash[:notice] = _('Task configuration was successfully updated.')
    
    respond_to do |format|
      format.html { redirect_to admin_tasks_path }
      format.xml { head :ok }
    end     
  end  

  def update
    @task = Retrospectiva::TaskManager::Task.find(params[:id])
    @task.update_attribute(:finished_at, @task.started_at) if @task.stale?
    respond_to do |format|
      format.html { redirect_to admin_tasks_path }
      format.xml { head :ok }
    end    
  end

end
