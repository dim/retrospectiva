#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class Admin::UsersController < AdminAreaController
  verify_restful_actions!  
  before_filter :paginate_users, :only => [:index, :search]
  before_filter :find_and_validate_user, :only => [:edit, :update]
  before_filter :find_groups, :only => [:new, :edit]
  before_filter :new, :only => [:create]

  def index
  end

  def search
    respond_to(:js)
  end

  def new
    @user = User.new(params[:user])
  end

  def create
    @user.send(:attributes=, params[:user], false)
    if @user.save
      flash[:notice] = _('User was successfully created.')
      redirect_to admin_users_path
    else
      find_groups
      render :action => 'new'
    end    
  end

  def edit
  end

  def update
    active_was = @user.active?
    @user.send(:attributes=, params[:user], false)
    if @user.save
      successful_update(active_was)
    else
      find_groups
      render :action => 'edit'
    end
  end

  def destroy
    user = User.find(params[:id])
    if user.destroy
      flash[:notice] = _('User was successfully deleted.')
    else
      flash[:error] = [_('User could not be deleted. Following error(s) occurred') + ':'] + user.errors.full_messages
    end
    redirect_to admin_users_path
  end

  protected
    
    def find_and_validate_user
      @user = User.find(params[:id])       
      redirect_to admin_users_path if @user.public?      
    end

    def paginate_users
      conditions = PlusFilter::Conditions.new do |c|
        c << ['users.id <> ?', User.public_user.id]
        c << Retro::Search::exclusive(params[:term], *User.searchable_column_names)
      end
      @users = User.paginate(
        :conditions => conditions.to_a,
        :order => 'users.admin DESC, users.name',
        :include => [:groups],
        :per_page => params[:per_page],
        :page => params[:page]
      )
    end
    
    def find_groups
      @groups = Group.find :all,
        :conditions => ['id <> ?', Group.default_group.id],
        :order => 'name'
    end
  
    def successful_update(active_was)
      flash[:notice] = [_('User was successfully updated.')]
      if @user.active? && !active_was
        flash[:notice] << _('User account was activated.')
        if admin_user_activation? && params[:send_notification]
          flash[:notice].first << (' ' + _('A notification was sent to the user.'))
          Notifications.queue_account_activation_note(@user)
        end
      end      
      redirect_to admin_users_path      
    end

  private

    def admin_user_activation?
      RetroCM[:general][:user_management][:activation] == 'admin'      
    end
  
end
