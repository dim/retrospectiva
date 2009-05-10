#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::ReportsController < AdminAreaController
  verify :xhr => true, :only => :sort

  before_filter :find_project
  before_filter :new, :only => [:create]
  before_filter :edit, :only => [:update]

  def index
    @ticket_reports = @project.ticket_reports
  end

  def new
    @ticket_report = @project.ticket_reports.new(params[:ticket_report])    
  end
  
  def create
    if @ticket_report.save
      flash[:notice] = _('Report was successfully created.')
      redirect_to admin_project_reports_path(@project)
    else
      render :action => 'new'
    end    
  end

  def edit
    @ticket_report = @project.ticket_reports.find(params[:id])
  end

  def update
    if @ticket_report.update_attributes(params[:ticket_report])
      flash[:notice] = _('Report was successfully updated.')
      redirect_to admin_project_reports_path(@project)
    else 
      render :action => 'edit'
    end    
  end
  
  def destroy
    if @project.ticket_reports.destroy(params[:id])
      flash[:notice] = _('Report was successfully deleted.')
    end
    redirect_to admin_project_reports_path(@project)
  end

  def sort
    params[:ticket_reports].each_with_index do |id, rank|      
      TicketReport.update_all ['rank = ?', rank], ['id = ? AND project_id = ?', id.to_i, @project.id]
    end if params[:ticket_reports].is_a?(Enumerable)
    render :nothing => true
  end

  private
  
    def find_project
      @project = Project.find_by_short_name! params[:project_id], 
        :include => [:ticket_reports],
        :order => 'ticket_reports.rank'
    end

end
