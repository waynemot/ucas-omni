#
# AppCtrlr base for CAS Omniauth
class ApplicationController < ActionController::Base

  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :correct_user?

  def authenticate_user!
    Rails.logger.info("app_ctrlr.authenticate_user fired!")
    unless @current_user
      redirect_to '/auth/cas', alert: "Sign in for access.", location_url: request.env['omniauth.origin'].presence || '/'
    end
  end

  # def after_sign_in_path_for resource_or_scope  # **** DEVISE HELPER PATH *****
  #   if request.env['omniauth.origin']
  #     redirect_to request.env['omniauth.origin']
  #   end
  # end

  private

  def user_signed_in?
    return true if @current_user
  end

  def correct_user?
    unless @current_user == @user
      redirect_to root_url, alert: 'Access denied, @current_user != @user...'
    end
  end

  def current_user (auth)
    if auth
      begin
        @current_user = User.from_omniauth(auth)
      rescue
        redirect_to root_url, alert: "couldn't find/set @current user from passed auth #{auth.inspect}"
      end
    else
      redirect_to root_url, alert: "Invalid Auth passed to App Controller.current_user"
    end
  end

  def get_current_user
    return @current_user
  end
end
