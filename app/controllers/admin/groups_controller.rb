#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::GroupsController < AdminAreaController
  before_filter :paginate_groups, :only => [:index]
  before_filter :find_projects, :only => [:new, :edit]
  before_filter :find_group, :only => [:edit, :update, :destroy]
  
  def index
    respond_to do |format|
      format.html
      format.xml  { render :xml => @groups.to_xml }
    end
  end

  def new
    @group = Group.new(params[:group])    

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  def create
    @group = Group.new(params[:group])    

    respond_to do |format|
      if @group.save
        flash[:notice] = _('Group was successfully created.')
        format.html { redirect_to admin_groups_path }
        format.xml  { render :xml => @group, :status => :created, :location => admin_groups_path }
      else
        find_projects
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = _('Group was successfully updated.')
        format.html { redirect_to admin_groups_path }
        format.xml  { head :ok }        
      else
        find_projects
        format.html { render :action => 'edit' }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end    
    end    
  end
  
  def destroy
    respond_to do |format|
      if @group.destroy
        flash[:notice] = _('Group was successfully deleted.')
        format.html { redirect_to(admin_groups_path) }
        format.xml  { head :ok }
      else
        flash[:error] = ([_('Group could not be deleted. Following error(s) occured') + ':'] + @group.errors.full_messages)
        format.html { redirect_to(admin_groups_path) }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  protected
    
    def find_group
      @group = Group.find(params[:id])     
    end
    
    def find_projects
      @projects = Project.find(:all, :order => 'name')
    end
  
    def paginate_groups
      @groups = Group.paginate(
        :order => "CASE groups.name WHEN 'Default' THEN 0 ELSE 1 END, groups.name",
        :per_page => params[:per_page],
        :page => params[:page]
      )
  end
  
end
