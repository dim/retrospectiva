class TicketReportsController < ProjectAreaController
  layout false
  menu_item :use => 'TicketsController'

  require_permissions :reports,
    :create => ['new', 'create', 'sort'],
    :delete => ['destroy']

  def new
    @ticket_report = Project.current.ticket_reports.new(params[:ticket_report])
    
    respond_to do |format|
      format.js
      format.xml  { render :xml => @ticket_report }
    end
  end

  def create
    @ticket_report = Project.current.ticket_reports.new(params[:ticket_report])

    respond_to do |format|
      if @ticket_report.save
        flash[:notice] = _('Report was successfully created.')
        format.js
        format.xml  { render :xml => @ticket_report, :status => :created, :location => @ticket_report }
      else
        format.js   { render :action => "new" }
        format.xml  { render :xml => @ticket_report.errors, :status => :unprocessable_entity }
      end
    end
  end

  def sort
    params[:ticket_reports].each_with_index do |id, rank|      
      Project.current.ticket_reports.update_all ['rank = ?', rank.to_i], ['id = ?', id.to_i]
    end if params[:ticket_reports].is_a?(Enumerable)

    respond_to do |format|
      format.html { render :nothing => true }
      format.xml  { head :ok }
    end    
  end

  def destroy
    @ticket_report = Project.current.ticket_reports.find(params[:id])
    @ticket_report.destroy
    flash[:notice] = _('Report was successfully deleted.')

    respond_to do |format|
      format.html { redirect_to project_tickets_path(Project.current) }
      format.xml  { head :ok }
    end
  end

  protected

    def protect_against_forgery?
      false
    end

end
