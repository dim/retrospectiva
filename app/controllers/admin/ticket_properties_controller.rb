#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::TicketPropertiesController < AdminAreaController 
  before_filter :find_project
  before_filter :new_property_type, :only => [:new, :create]
  before_filter :find_property_type, :only => [:edit, :update, :destroy]

  def index
    @ticket_properties = @project.ticket_property_types
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @ticket_properties }
    end
  end
  
  def new
    respond_to do |format|
      format.html
      format.xml { render :xml => @ticket_property_type }
    end
  end
  
  def create
    respond_to do |format|
      if @ticket_property_type.save
        flash[:notice] = _('Ticket property was successfully created.')
        format.html { redirect_to admin_project_ticket_properties_path(@project) }
        format.xml  { render :xml => @ticket_property_type, :status => :created, :location => admin_project_ticket_properties_path(@project) }        
      else
        format.html { render :action => 'new' }
        format.xml  { render :xml => @ticket_property_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @ticket_property_type.update_attributes(params[:ticket_property_type])
        flash[:notice] = _('Ticket property was successfully updated.')
        format.html { redirect_to admin_project_ticket_properties_path(@project) }
        format.xml  { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @ticket_property_type.errors, :status => :unprocessable_entity }        
      end
    end
  end

  def destroy
    @ticket_property_type.destroy
    flash[:notice] = _('Ticket property was successfully deleted.')

    respond_to do |format|
      format.html { redirect_to admin_project_ticket_properties_path(@project) }
      format.xml  { head :ok }
    end      
  end

  def sort
    params[:ticket_properties].each_with_index do |id, rank|      
      @project.ticket_property_types.update_all ['rank = ?', rank], ['id = ?', id.to_i]
    end if params[:ticket_properties].is_a?(Enumerable)

    respond_to do |format|
      format.html { render :nothing => true }
      format.xml  { head :ok }
    end    
  end
  
  protected
  
    def new_property_type
      @ticket_property_type = @project.ticket_property_types.new(params[:ticket_property_type])     
    end
  
    def find_property_type
      @ticket_property_type = @project.ticket_property_types.find(params[:id])      
    end
  
    def find_project
      @project = Project.find_by_short_name! params[:project_id], 
        :include => [:ticket_property_types],
        :order => 'ticket_property_types.rank'
    end
end
