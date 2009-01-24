#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::GroupsController < AdminAreaController
  verify_restful_actions!  
  before_filter :paginate_groups, :only => [:index]
  before_filter :find_projects, :only => [:new, :edit]
  before_filter :new, :only => [:create]
  before_filter :edit, :only => [:update]
  
  def index
  end

  def new
    @group = Group.new(params[:group])    
  end

  def create
    if @group.save
      flash[:notice] = _('Group was successfully created.')
      redirect_to admin_groups_path
    else
      find_projects
      render :action => 'new'
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    if @group.update_attributes(params[:group])
      flash[:notice] = _('Group was successfully updated.')
      redirect_to admin_groups_path
    else
      find_projects
      render :action => 'edit'
    end    
  end
  
  def destroy
    group = Group.find params[:id]
    if group.destroy
      flash[:notice] = _('Group was successfully deleted.')
    else
      flash[:error] = ([_('Group could not be deleted. Following error(s) occured') + ':'] + group.errors.full_messages)
    end
    redirect_to admin_groups_path
  end
  
  protected
    
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
