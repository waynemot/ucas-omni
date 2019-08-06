#
# AppCtrlr base for CAS Omniauth
class ApplicationController < ActionController::Base

  helper_method :set_current_user
  helper_method :user_signed_in?
  helper_method :correct_user?
  helper_method :current_user

  @session_user = nil

  def authenticate_user!
    Rails.logger.info("app_ctrlr.authenticate_user fired!")
    logger.info "current_user: #{current_user}"

    unless @session_user
      response.headers["referer"] = request.env['omniauth.origin']&.presence || '/'
      session['referer'] = request.env['omniauth.origin']
      redirect_to '/auth/cas', alert: "Sign in for access." # , location_url: request.env['omniauth.origin']&.presence || '/'
    end
  end

  def current_user
    logger.info "DEBUG: current_user: [#{@session_user&.inspect}];"
    @session_user
  end

  def current_user_logout
    Authorization.find_by_uid(@session_user.login_id).destroy!
    @session_user = nil
  end

  private

  def user_signed_in?
    return true if @session_user
  end

  def correct_user?
    unless @session_user == @user
      redirect_to root_url, alert: 'Access denied, @current_user != @user...'
    end
  end

  def set_current_user (auth)
    if auth
      begin
        session[:authorized_as_user] = auth[:uid]
        #session[:user] = auth[:uid]
        @session_user = new Identity (session)
      rescue
        redirect_to root_url, alert: "couldn't find/set @current user from passed auth #{auth.inspect}"
      end
    else
      redirect_to root_url, alert: "Invalid Auth passed to App Controller.current_user"
    end
  end

end
