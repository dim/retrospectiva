#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class TicketsController < ProjectAreaController
  keep_params! :only => [:index], :exclude => [:project_id]

  menu_item :tickets, :except => [:new, :create] do |i|
    i.label = N_('Tickets')
    i.rank = 400
  end

  menu_item :new_ticket, :only => [:new, :create] do |i|
    i.label = N_('New Ticket')
    i.path = lambda do |project|
      new_project_ticket_path(project)
    end
    i.rank = 500
  end

  require_permissions :tickets,
    :view   => ['index', 'search', 'show', 'download', 'users'],
    :create => ['new', 'create'],
    :update => ['update'],
    :delete => ['destroy', 'destroy_change'],
    :watch  => ['toggle_subscription']

  require_user 'modify_summary', 'modify_content', 'modify_change_content'
  
  enable_private_rss :only => :index

  verify        :xhr => true, :only => [:modify_summary, :modify_content, :modify_change_content]

  before_filter :find_report, :only => [:index, :search]
  before_filter :setup_filters, :only => [:index, :search]

  before_filter :find_reports, :only => [:index]
  before_filter :find_ticket, :only => [:show, :update, :destroy, :toggle_subscription]
  before_filter :new_change, :only => [:show, :update]
  before_filter :new_ticket, :only => [:new, :create]

  before_filter :find_ticket_and_verify_permissions, :only => [:modify_summary, :modify_content]
  before_filter :find_change_and_verify_permissions, :only => [:modify_change_content]

  before_filter :find_and_verify_attachment, :only => :download
    
  def index
    @tickets = paginate_tickets(request.format.rss? ? 10 : params[:per_page])    
    respond_with_defaults
  end

  def search
    @tickets = paginate_tickets(nil)
    respond_to(:js)
  end

  def show
    filters = TicketFilter::Collection.new(stored_params, Project.current)
    @next_ticket = @ticket.next_ticket(filters)
    @previous_ticket = @ticket.previous_ticket(filters)    
    @ticket_change.attributes = { :author => cached_user_attribute(:name, 'Anonymous'), :email => cached_user_attribute(:email) }
  end

  def new
    @ticket.author = cached_user_attribute(:name, 'Anonymous')
    @ticket.email = cached_user_attribute(:email)
  end

  def create
    @ticket.protected_attributes = params[:ticket]
    @ticket.author_host = request.remote_ip
    @ticket.toggle_subscriber(User.current) if params[:watch_ticket]
    if @ticket.save
      cache_user_attributes!(:name => @ticket.author, :email => @ticket.email)
      flash[:notice] = _('Ticket was successfully created.')
      redirect_to project_ticket_path(Project.current, @ticket)
    else
      render :action => 'new'
    end
  end

  def update
    if @ticket_change.save
      @ticket.toggle_subscriber(User.current) if params[:watch_ticket]
      cache_user_attributes!(:name => @ticket_change.author, :email => @ticket_change.email)
      flash[:notice] = _('Ticket was successfully updated.')
      redirect_to project_ticket_path(Project.current, @ticket, :anchor => "ch#{@ticket_change.id}")
    else
      render :action => 'show'
    end
  end

  def download
    send_file *@attachment.send_arguments
  end

  def toggle_subscription
    flash[:notice] = if @ticket.toggle_subscriber(User.current)
      _('You are now watching this ticket.')
    else
      _('You stopped watching this ticket.')
    end
    redirect_to project_ticket_path(Project.current, @ticket)
  end

  def destroy
    if @ticket.destroy
      flash[:notice] = _('Ticket was successfully deleted.')
    end
    redirect_to project_tickets_path(Project.current)
  end

  def destroy_change
    @ticket_change = Project.current.ticket_changes.find params[:id], :include => :ticket
    @ticket = @ticket_change.ticket
    if @ticket_change.destroy
      updated_at = (@ticket.changes.last || @ticket).created_at
      @ticket.update_timestamp(updated_at)
      flash[:notice] = _('Ticket change was successfully deleted.')
    end
    redirect_to project_ticket_path(Project.current, @ticket_change.ticket)
  end

  def modify_summary
    @summary = @ticket.update_attribute_without_timestamps(:summary, params[:value]) ? @ticket.summary : @ticket.summary_was
    render :inline => '<%= h(@summary) %>'
  end

  def modify_content
    @content = @ticket.update_attribute_without_timestamps(:content, params[:value]) ? @ticket.content : @ticket.content_was
    render :inline => '<%= markup(@content) %>'
  end

  def modify_change_content
    @content = @ticket_change.update_attribute(:content, params[:value]) ? @ticket_change.content : @ticket_change.content_was
    render :inline => '<%= markup(@content) %>'
  end

  def users
    if RetroCM[:ticketing][:user_assignment][:field_type] == 'text-field' 
      @users = Project.current.users.with_permission(:tickets, :update).select do |record|
        record.name.downcase.include?(params[:assigned_user].to_s.downcase)
      end.first(5)
      render :layout => false
    else
      raise ActionController::UnknownAction
    end
  end

  protected

    def find_report
      @report = Project.current.ticket_reports.find_by_id params[:report]
      params.merge!(@report.filter_options) if @report
    end

    def setup_filters
      @filters = TicketFilter::Collection.new(params, Project.current)
    end

    def find_reports
      @reports = Project.current.ticket_reports.find :all, :order => 'rank'
    end

    def find_ticket
      @ticket = Project.current.tickets.find_by_id params[:id],
        :include => Ticket.default_includes,
        :order => 'ticket_changes.created_at'
      redirect_to project_tickets_path(Project.current) unless @ticket
    end

    def new_ticket
      params[:ticket] = params[:ticket].is_a?(Hash) ? params[:ticket] : {}
      @ticket = Project.current.tickets.new(params[:ticket])
    end

    def new_change
      params[:ticket_change] = params[:ticket_change].is_a?(Hash) ? params[:ticket_change] : {}
      @ticket_change = @ticket.changes.new
      @ticket_change.attributes = params[:ticket_change]
    end

    def find_ticket_and_verify_permissions
      @ticket = Project.current.tickets.find(params[:id])
      failed_authorization! unless permitted?(:tickets, :modify, @ticket)
    end

    def find_change_and_verify_permissions
      @ticket_change = Project.current.ticket_changes.find(params[:id])
      failed_authorization! unless permitted?(:tickets, :modify, @ticket_change)
    end

    def find_and_verify_attachment
      @attachment = Attachment.find params[:id], :include => :attachable
      @attachment.readable? && case @attachment.attachable
      when Ticket
        params[:ticket_id].to_i == @attachment.attachable.id
      when TicketChange
        params[:ticket_id].to_i == @attachment.attachable.ticket_id
      else
        false
      end || raise(ActiveRecord::RecordNotFound, "Couldn't find #{@attachment.class} with ID=#{params[:id]}")
    end

  private

    def paginate_tickets(per_page)
      conditions = PlusFilter::Conditions.new(@filters.conditions) do |c|
        c << ['tickets.updated_at > ?', @report.since] if @report && @report.since
        c << Retro::Search.conditions(params[:term], *Ticket.searchable_column_names)
      end.to_a

      Project.current.tickets.paginate(
        :page => params[:page],
        :per_page => per_page,
        :conditions => conditions,
        :include => Ticket.default_includes,
        :joins => @filters.joins,
        :order => 'tickets.updated_at DESC, ticket_changes.created_at')
    end

    def stored_params
      stored = session[:params_keeper]["#stored{self.class.controller_path}/index"] rescue nil
      stored || {}
    end

end
