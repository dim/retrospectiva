#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::TasksController < AdminAreaController
  verify_action :save, :method => :put, :params => :tasks

  def index
    @tasks  = Retrospectiva::Tasks.tasks
  end
  
  def save
    configuration = params[:tasks].inject({}) do |result, (name, interval)|
      seconds = TimeInterval.in_seconds(interval[:count], interval[:units]) rescue 0
      result.merge name => seconds
    end
    Retrospectiva::Tasks.update(configuration)
    flash[:notice] = _('Task configuration was successfully updated.')
    redirect_to admin_tasks_path
  end  

end
