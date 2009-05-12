class TicketReportsController < ProjectAreaController
  require_permissions :reports,
    :create => ['new', 'create'],
    :delete => ['destroy']

  def new
    @ticket_report = Project.current.ticket_reports.new

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

  def destroy
    @ticket_report = Project.current.ticket_reports.find(params[:id])
    @ticket_report.destroy

    respond_to do |format|
      format.js
      format.xml  { head :ok }
    end
  end

end
