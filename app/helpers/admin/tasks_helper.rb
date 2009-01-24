#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
module Admin::TasksHelper

  def select_interval(task)
    interval = task.interval > 0 ? TimeInterval.match(task.interval, 0..60) : nil
      
    time_interval_select_tag "tasks[#{task.name}]", 
      :range => 0..60,
      :units => interval ? interval.last : 'minutes',
      :count => interval ? interval.first : 0
  end

end
