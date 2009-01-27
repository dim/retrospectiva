module Retrospectiva
  module AccessManager
    module SecureController

      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        [:before_authenticate, :after_authenticate].each do |method|
          base.class_eval <<-END_EVAL
            def self.#{method}(*callbacks, &block)
              callbacks << block if block_given?
              write_inheritable_array(#{method.to_sym.inspect}, callbacks)
            end
          END_EVAL
        end
      end

      # == Step-wise action protection
      #
      # This module provides class-level methods for more modular access
      # restriction definitions. Using the authorize filter
      # allows all actions being accessed by supervisor only. The 'require_*'
      # methods can be used to ease this restriction.
      #
      # Available methods:
      # * require_permissions
      # * require_user
      #
      # See the documentation of each method for more details.
      #
      module ClassMethods
        # Returns true if the user is logged in and also permitted to access the
        # action (given by the action_name parameter), else false.
        #
        # The before_filter :authorize u.A. uses this method to determine if access
        # should be granted or refused.
        def authorize?(action_name, request_params = {}, user = User.current, project = nil)
          action_name = action_name.to_s

          if user.blank?
            false
          elsif user.admin?
            true
          elsif project && require_permissions.key?(action_name)
            require_permissions[action_name].map do |tokens|
              tokens << { :project => project }
              user.permitted?(*tokens)
            end.uniq == [true]
          else
            require_user.include?(action_name)
          end
        end

        # This restricts action access to admins and users that have a permission
        #
        #     require_permissions :tickets,
        #       :view => ['index', 'show'],
        #       :update => ['edit', 'update']
        #
        def require_permissions(resource = nil, options = {})
          ensure_authorize_before_filter!

          returning(@retro_am_auth_require_permissions ||= {}) do |permission_map|

            options.each do |permission, actions|
              [actions].flatten.map(&:to_s).each do |action|
                permission_map[action] ||= []
                permission_map[action] << [resource.to_sym, permission.to_sym]
              end
            end if resource.present?

          end
        end

        # This restricts action access to all logged-in users (also Public). Arguments may contain
        # an arbitrary number of method references. Example:
        #
        #     require_user('list', 'view')
        #
        def require_user(*actions)
          ensure_authorize_before_filter!
          returning(@retro_am_auth_require_user ||= []) do |permissions|
            permissions += actions.map(&:to_s) unless actions.blank?
          end
        end

        def authorized_controller?
          before_filters.include?(:authorize) || before_filters.include?('authorize')
        end

        private

          def ensure_authorize_before_filter!
            raise Error, "Unable to find an 'authorize' before_filter." unless authorized_controller?
          end
      end


      # This module provides two ready-made before_filters that can easily be
      # included to secure a controller:
      #
      # * authenticate
      # * authorize
      #
      # See the documentation of each filter for more details.
      #
      module InstanceMethods
        protected
          # This filter is generally used to protect actions from being accessed
          # by non logged-in users. Example:
          #
          #   class SomeController < ActionController::Base
          #     # You must be logged-in to access this controller's actions
          #     before_filter :authenticate
          #
          def authenticate
            result = security_callback(:before_authenticate)
            return false if result == false

            if session[:user_id].is_a?(Integer)
              logger.debug("Authenticating user with id = #{session[:user_id]}") if logger
              User.current = User.find_by_id session[:user_id], :include => {:groups => :projects}
            else
              User.current = User.public_user
              raise "You have no Public user. See the INSTALL file for instructions on setting up default content." unless User.current
            end

            if User.current.blank?
              logger.debug("Authentication failed. Redirect to login.") if logger
              reset_session
              redirect_to login_path
              return false
            end

            security_callback(:after_authenticate)
          end

          def before_authenticate() end
          def after_authenticate() end

          # This filter restricts action access to a specific user-level. Potential
          # user levels are:
          #
          # * admin:           access to admins only
          # * permission:      access to admins and those logged-in who have a permission
          # * login:           access to all logged-in users
          #
          # The authorize filter follows a 'deny all then allow some' strategy, i.e.
          # primarily, actions will be guarded from beeing accesses by any other than
          # admin. This restriction can be reduced stepwise by using require_*
          # class-level definitions, described in next chapter. Example:
          #
          #   class SomeController < ActionController::Base
          #     # You must be supervisor to access this controller's actions
          #     before_filter :authorize
          #
          def authorize
            authenticate unless User.current
            raise ActionController::UnknownAction unless self.class.action_methods.include?(action_name)
            refuse_authorization! unless self.class.authorize?(action_name, params, User.current, Project.current)
            return true
          end

          def refuse_authorization!
            raise NoAuthorizationError, "No authorization for action: #{action_name}, params: #{params.inspect}, user: #{User.current.username rescue 'nil'}, project: #{Project.current.name rescue 'nil'}"
          end

        private

          def security_callback(method)
            methods = self.class.read_inheritable_attribute(method.to_sym) || []
            methods.each do |callback|
              result = send(callback)
              return false if result == false
            end
            send(method)
          end

      end

    end
  end
end
