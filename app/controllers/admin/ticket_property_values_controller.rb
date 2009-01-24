#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::TicketPropertyValuesController < AdminAreaController 
  verify_restful_actions!
  verify_action :sort, :method => :put, :xhr => true

  before_filter :find_project
  before_filter :find_property_type

  before_filter :find_values, :only => [:index]
  before_filter :find_value, :only => [:edit, :update, :destroy]
  before_filter :new, :only => [:create]

  def index
  end

  def new
    @ticket_property = if @property_type.global?
      @property_type.new(params[param_name])
    else
      @property_type.ticket_properties.new(params[param_name])
    end
  end

  def create
    if @ticket_property.save      
      flash[:notice] = @property_type.global? ?      
        _('{{record}} was successfully created.', :record => @property_type.name) :
        _('Property value was successfully created.')
      redirect_to admin_project_ticket_property_values_path(@project, @property_type)
    else
      render :action => 'new'
    end  
  end

  def edit
  end

  def update
    if @ticket_property.update_attributes(params[param_name])
      flash[:notice] = _('Property value was successfully updated.')
      redirect_to admin_project_ticket_property_values_path(@project, @property_type)
    else
      render :action => 'edit'
    end    
  end

  def destroy
    if @ticket_property.destroy
      flash[:notice] = _('Property value was successfully deleted.')
    end
    redirect_to admin_project_ticket_property_values_path(@project, @property_type)
  end

  def sort
    klass = @property_type.global? ? @property_type : TicketProperty
    params[:property_values].each_with_index do |id, rank|      
      klass.update_all ['rank = ?', rank], ['id = ?', id.to_i]
    end if params[:property_values].is_a?(Enumerable)
    render :nothing => true
  end

  protected 

    def param_name
      @property_type.global? ? @property_type.class_name.underscore : :ticket_property
    end
  
    def find_project
      @project = Project.find_by_short_name params[:project_id]
      project_not_found(params[:project_id]) unless @project
    end

    def find_property_type
      @property_type = if ['Status', 'Priority'].include?(params[:ticket_property_id])
        params[:ticket_property_id].constantize
      elsif params[:ticket_property_id].to_i > 0
        @project.ticket_property_types.find params[:ticket_property_id], :include => [:ticket_properties]        
      else
        raise ActiveRecord::RecordNotFound, "Couldn't find TicketPropertyType with ID=#{params[:ticket_property_id]}"
      end
    end
    
    def find_values
      @property_values = if @property_type.global?
        @property_type.find(:all, :order => 'rank')    
      else
        @property_type.ticket_properties
      end
    end

    def find_value
      @ticket_property = if @property_type.global?
        @property_type.find(params[:id])
      else
        @property_type.ticket_properties.find(params[:id])
      end
    end

end
