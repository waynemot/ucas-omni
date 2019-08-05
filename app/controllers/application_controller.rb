#
# AppCtrlr base for CAS Omniauth
class ApplicationController < ActionController::Base

  helper_method :set_current_user
  helper_method :user_signed_in?
  helper_method :correct_user?
  helper_method :current_user

  def authenticate_user!
    Rails.logger.info("app_ctrlr.authenticate_user fired!")
    unless @current_user
      response.headers["referrer"] = request.env['omniauth.origin']&.presence || '/'
      redirect_to '/auth/cas', alert: "Sign in for access." # , location_url: request.env['omniauth.origin']&.presence || '/'
    end
  end

  def current_user
    logger.info "DEBUG: current_user: [#{@current_user&.inspect}];"
    @current_user
  end

  def current_user_logout
    @current_user = nil
  end

  private

  def user_signed_in?
    return true if @current_user
  end

  def correct_user?
    unless @current_user == @user
      redirect_to root_url, alert: 'Access denied, @current_user != @user...'
    end
  end

  def set_current_user (auth)
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

end
