#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::TicketPropertiesController < AdminAreaController 
  verify :xhr => true, :only => :sort

  before_filter :find_project
  before_filter :new, :only => [:create]
  before_filter :edit, :only => [:update]

  def index
    @ticket_properties = @project.ticket_property_types
  end
  
  def new
    @ticket_property_type = @project.ticket_property_types.new(params[:ticket_property_type])
  end
  
  def create
    if @ticket_property_type.save
      flash[:notice] = _('Ticket property was successfully created.')
      redirect_to admin_project_ticket_properties_path(@project)
    else
      render :action => 'new'
    end
  end

  def edit
    @ticket_property_type = @project.ticket_property_types.find(params[:id])
  end

  def update
    if @ticket_property_type.update_attributes(params[:ticket_property_type])
      flash[:notice] = _('Ticket property was successfully updated.')
      redirect_to admin_project_ticket_properties_path(@project)
    else
      render :action => 'edit'
    end
  end

  def destroy
    if @project.ticket_property_types.destroy(params[:id])
      flash[:notice] = _('Ticket property was successfully deleted.')
    end
    redirect_to admin_project_ticket_properties_path(@project)    
  end

  def sort
    params[:ticket_properties].each_with_index do |id, rank|      
      TicketPropertyType.update_all ['rank = ?', rank], ['id = ? AND project_id = ?', id.to_i, @project.id]
    end if params[:ticket_properties].is_a?(Enumerable)
    render :nothing => true
  end
  
  protected
  
    def find_project
      @project = Project.find_by_short_name params[:project_id], 
        :include => [:ticket_property_types],
        :order => 'ticket_property_types.rank'
      project_not_found(params[:project_id]) unless @project
    end
end
