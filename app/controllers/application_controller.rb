#
# AppCtrlr base for CAS Omniauth
class ApplicationController < ActionController::Base

  helper_method :set_current_user
  helper_method :user_signed_in?
  helper_method :correct_user?
  helper_method :current_user

  @session_user

  def authenticate_user!
    Rails.logger.info("DEBUG: app_ctrlr.authenticate_user fired!")

    if @session_user.nil? || @session_user.empty?
      Rails.logger.info "DEBUG: session empty or null, redirect to authentication..."
      response.headers["referer"] = request.env['omniauth.origin'].presence || '/'
      session['referer'] = request.env['omniauth.origin']
      redirect_to users_sign_in_url
      #redirect_to '/auth/cas', alert: "Sign in for access."
    else
      Rails.logger.info "@session_user exists in authenticate_user!"
      unless @session_user.authorized_as_user.nil?
        if @session_user.authorized_as_user.empty?
          Rails.logger.info "@session_user.authorized_as_user is empty.  "
        end
        Rails.logger.info "@session_user has authorized as user value set: #{@session_user.authorized_as_user}"
        session[:authorized_as_user] = @session_user.authorized_as_user
      else
        Rails.logger.info "@session_user.authorized_as_user is _NULL_, so no session. Remove @session_user"
        @session_user = nil
      end
    end
  end

  def current_user
    # if @session_user.nil?
    #   @session_user = Identity.new(session)
    # end
    logger.info "DEBUG: current_user: [#{@session_user&.inspect}];"
    @session_user
  end

  def current_user_logout
    if params[:authenticity_token] && params[:method] == :delete
      Authorization.destroy(params[:authenticity_token])
    elsif @session_user && @session_user.login_id
      Authorization.find_by_uid(@session_user.login_id).destroy!
    else
      Rails.logger.info "ERROR: Authentication could not be removed..."
    end
    @session_user = nil
  end

  private

  def user_signed_in?
    return true if @session_user && @session_user&.authorized_as_user && @session_user&.login_id
  end

  def correct_user?
    unless @session_user.identity
      redirect_to root_url, alert: 'Access denied, @current_user != @user...'
    end
  end

  def set_current_user (auth, session)
    logger.info "DEBUG: app_ctrl.set_current_user: auth passed: #{auth.inspect}"
    if auth
      begin
        session[:authorized_as_user] = auth[:uid]  # :uid = CSE LOGIN ID USED CAS SERVER
        @session_user = Identity.new(session)
      rescue
        logger.info "DEBUG: OUCH! Rescue fired on session setup"
        #redirect_to root_url, alert: "couldn't find/set @current user from passed auth #{auth.inspect}"
      end
    else
      redirect_to root_url, alert: "Invalid Auth passed to App Controller.current_user"
    end
  end

end
