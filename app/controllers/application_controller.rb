#
# AppCtrlr base for CAS Omniauth
class ApplicationController < ActionController::Base

  helper_method :set_current_user
  helper_method :user_signed_in?
  helper_method :correct_user?
  helper_method :current_user

  @session_user

  def authenticate_user!
    Rails.logger.info("app_ctrlr.authenticate_user fired!")
    logger.info "current_user: #{current_user}"

    if @session_user.nil?
      response.headers["referer"] = request.env['omniauth.origin'].presence || '/'
      session['referer'] = request.env['omniauth.origin']
      redirect_to '/auth/cas', alert: "Sign in for access."
    else
      logger.info "@session_user exists in authenticate_user!"
      unless @session_user.authorized_as_user.nil?
        if @session_user.authorized_as_user.empty?
          logger.info "@session_user.authorized_as_user is empty.  "
        end
        logger.info "@session_user has authorized as user value set: #{@session_user.authorized_as_user}"
        session[:authorized_as_user] = @session_user.authorized_as_user
      else
        logger.info "@session_user.authorized_as_user is '#{@session_user.authorized_as_user}'"
      end
      if @session_user.user.nil?
        logger.info "@session_user.user is NULL..."
      end
    end
  end

  def current_user
    if @session_user.nil?
      @session_user = Identity.new(session)
    end
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
    unless @session_user.identity
      redirect_to root_url, alert: 'Access denied, @current_user != @user...'
    end
  end

  def set_current_user (auth, session)
    # debugger
    logger.info "DEBUG: app_ctrl.set_current_user: auth passed: #{auth.inspect}"
    if auth
      begin
        session[:authorized_as_user] = auth[:uid]
        #session[:user] = auth[:uid]
        @session_user = new Identity(session)
      rescue
        logger.info "DEBUG: OUCH! Rescue fired on session setup"
        redirect_to root_url, alert: "couldn't find/set @current user from passed auth #{auth.inspect}"
      end
    else
      redirect_to root_url, alert: "Invalid Auth passed to App Controller.current_user"
    end
  end

end
