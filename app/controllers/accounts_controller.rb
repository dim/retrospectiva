#--
# Copyright (C) 2009 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class AccountsController < ApplicationController
  
  before_filter :account_management_enabled?
  before_filter :registration_enabled?, :only => [:new, :create]
  before_filter :activation_enabled?, :only => [:activate]
  
  before_filter :user_has_valid_login_token?, :only => [:show]
  before_filter :user_is_non_public?, :only => [:show, :update]
  before_filter :user_is_public?, :only => [:new, :create, :activate, :forgot_password]

  before_filter :assert_user_parameter, :only => [:create, :update]
  before_filter :purge_expired_accounts, :only => [:create, :activate]
  before_filter :assign_user, :only => [:show, :update]
  before_filter :new_user, :only => [:new, :create]

  def show
    respond_to do |format|
      format.html
      format.xml { render :xml => user_xml }
    end
  end

  def update
    @user.attributes = params[:user]
    @user.reset_private_key if params[:reset_private_key]
    respond_to do |format|
      if @user.save
        flash[:notice]  = _('User account was successfully updated.')
        format.html { redirect_to account_path }
        format.xml  { render :xml => user_xml, :status => :created, :location => account_path }        
      else
        format.html { render :action => 'show' }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end    
    end
  end

  def new
  end
  
  def create
    @user.attributes = params[:user]
    @user.username = params[:user][:username]
    @user.email = params[:user][:email]    
    if @user.save
      successful_registration
    else
      failed_registration
    end
  end

  def activate
    if params[:username] && params[:code]
      user = User.find_by_username_and_activation_code(params[:username], params[:code])      
      successful_activation(user) if user
    end
  end

  def forgot_password
    user = request.post? ? User.identify(params[:username_or_email]) : nil 
    if user
      flash[:notice] = _('Thank you.') + ' ' + _('Shortly you will receive an email with instructions on how to reset your password.')
      Notifications.queue_password_reset_instructions(user)
      redirect_to login_path
    end
  end

  protected

    # Ensure self-account-management is enabled
    def account_management_enabled?
      configured?(:account_management) || raise_unknown_action_error
    end

    # Ensure self-registration is enabled
    def registration_enabled?
      configured?(:self_registration) || raise_unknown_action_error 
    end

    # Ensure account activation is set to 'email'
    def activation_enabled?
      configured?(:activation, 'email') || raise_unknown_action_error
    end

    def user_has_valid_login_token?
      return true unless User.current.public? 

      token = LoginToken.spend(params[:lt])
      if token and token.user
        User.current = token.user
        session[:user_id] = token.user.id
      end
    end

    def user_is_non_public?
      redirect_to login_path if User.current.public?
    end

    def user_is_public?
      redirect_to root_path unless User.current.public?
    end
    
    def assert_user_parameter
      params[:user] = {} unless params[:user].is_a?(Hash)
      true
    end

    def new_user
      @user = User.new    
    end
  
    def assign_user
      @user = User.current
    end

    def purge_expired_accounts
      threshold = config[:expiration].hours.ago
      User.destroy_all ['activation_code IS NOT NULL AND active = ? AND created_at < ?', false, threshold]            
    end

    def successful_registration
      flash[:notice] = [_('User account was successfully created.')]      
      case config[:activation]
      when 'admin'
        flash[:notice] += [
          _('You are not allowed to login until your account has been activated by the administrator.')
        ]
        redirect_to login_path        
      when 'email'
        Notifications.queue_account_validation(@user)
        flash[:notice] += [
          _('You need to activate your account within the next %{count} hours to be able to login.', :count => config[:expiration]),
          _('An email including the activation code and the instructions was sent to you.')
        ]
        redirect_to account_activate_path
      else
        redirect_to login_path
      end
    end

    def failed_registration(error_messages = nil)
      flash[:error] = error_messages unless error_messages.blank?
      render :action => 'new'      
    end  

    def successful_activation(user)
      user.activation_code = nil 
      user.active = true
      if user.save
        flash[:notice] = _('User account was successfully activated. You can now login.')
        redirect_to login_path
      end
    end
  
  private

    def configured?(option, value = true)
      config[option] == value   
    end

    def config
      RetroCM[:general][:user_management]
    end
  
    def raise_unknown_action_error
      raise ::ActionController::UnknownAction, 'Action is hidden', caller
    end  

    def user_xml
      @user.to_xml(:merge => {:only => [:email, :time_zone]})      
    end
  
end
