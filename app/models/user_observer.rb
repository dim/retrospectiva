#--
# Copyright (C) 2008 Dimitrij Denissenko
# Please read LICENSE document for more information.
#++
class UserObserver < ActiveRecord::Observer

  def before_validation(user)
    normalize_time_zone(user)
    manage_group_associations(user)
  end

  def after_validation(user)    
    user.reset_password(user.plain_password) unless user.plain_password.blank?
    true
  end

  def after_save(user)
    user.plain_password = user.plain_password_confirmation = nil
    true
  end

  # * Assigns the user to user groups as defined in the configuration
  # * Sets the activation attributes based on configuration
  def before_create(user)
    group_ids = RetroCM[:general][:user_management][:assign_to_groups]
    Group.find_all_by_id(group_ids).each do |group|
      user.groups << group
    end unless group_ids.blank?

    case RetroCM[:general][:user_management][:activation]
    when 'admin'
      user.active = false
    when 'email'
      user.active = false
      user.reset_activation_code
    end
    
    true
  end

  private
    
    def normalize_time_zone(user)
      return true unless user.time_zone
      
      mapping = ActiveSupport::TimeZone::MAPPING
      if mapping.values.include?(user.time_zone)
        user.time_zone = mapping.invert[user.time_zone]        
      end || true
    end

    def manage_group_associations(user)
      if user.admin?
        user.groups.clear
      elsif !user.groups.include?(Group.default_group)
        user.groups << Group.default_group
      end
      true
    end

end
