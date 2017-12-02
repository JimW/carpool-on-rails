class ApplicationController < ActionController::Base

  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery prepend: true, with: :exception
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

protected
    def after_sign_in_path_for(resource_or_scope)
      # session[:current_carpool_id] = current_user.last_used_carpool_id
      if current_user.is_admin? #|| current_user.carpools.count > 1
        admin_carpools_path
      else
        if current_user.is_manager?(current_user.current_carpool)
          admin_routes_path
        else
          admin_user_path(current_user.id)
        end
      end
    end

  # Not sure this is ever working through Activeadmin... !!!
  # Need this to work because then I can redirect to the appropriate page, based on the exeptions !!!
  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    flash[:error] = t "#{policy_name}.#{exception.query}", scope: "pundit", default: :default
    self.response_body = nil # This should resolve the redirect root.
    redirect_to(request.referrer || root_path)
  end

  def access_denied(exception)
    flash[:alert] = "You were not authorized so have been redirected here."
    redirect_to(request.referrer || root_path)
  end

end
