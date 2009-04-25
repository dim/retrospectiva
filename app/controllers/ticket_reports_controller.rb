class TicketReportsController < ProjectAreaController

  def new
    @ticket_report = TicketReport.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ticket_report }
    end
  end

  def create
    @ticket_report = TicketReport.new(params[:ticket_report])

    respond_to do |format|
      if @ticket_report.save
        flash[:notice] = 'TicketReport was successfully created.'
        format.html { redirect_to(@ticket_report) }
        format.xml  { render :xml => @ticket_report, :status => :created, :location => @ticket_report }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ticket_report.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @ticket_report = TicketReport.find(params[:id])
    @ticket_report.destroy

    respond_to do |format|
      format.html { redirect_to(ticket_reports_url) }
      format.xml  { head :ok }
    end
  end

end
