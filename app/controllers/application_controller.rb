#
# AppCtrlr base for CAS Omniauth
class ApplicationController < ActionController::Base

  helper_method :set_current_user
  helper_method :user_signed_in?
  helper_method :correct_user?
  helper_method :current_user

  def authenticate_user!
    Rails.logger.info("DEBUG: app_ctrlr.authenticate_user fired!")

    if current_user.nil? || current_user.empty? #@session_user.nil? || @session_user.empty?
      Rails.logger.info "DEBUG: current_user returns empty or null, redirect to authentication..."
      if session['current_user'].present?
        Rails.logger.info "SESSION[current_user] present"
        curr = session['current_user']
        Rails.logger.info "contents of current_user: #{curr.inspect}"
        @session_user = curr
        unless @session_user['authorized_as_user'].nil?
          if @session_user['authorized_as_user'].empty?
            Rails.logger.info "DEBUG: current_user was nil, have session[current_user] but authorized_as_user is empty..."
          end
          if session['authorized_as_user'].present?
            Rails.logger.info "DEBUG: HOWEVER, session has authorized as user present: #{session['authorized_as_user']}"
            logger.info "DEBUG: should be logged in. redirect to requested dest"
            logger.info "request.env[omniauth.origin] '#{request.env["omniauth.origin"]}'"
            logger.info "session keys: #{session.keys}"
            logger.info "session[destination]: #{session['destination']}"
            logger.info "request[referer]: '#{request[:referer]}'"
            unless session['destination'].nil?
              udest = session['destination']
              session['destination'] = nil
              redirect_to udest
            end
          end
        end
      end
      Rails.logger.info "DEBUG: omniauth.origin: '#{request.env['omniauth.origin']}'"
      Rails.logger.info "DEBUG: request.env[REQUEST_PATH]: #{request.env["REQUEST_PATH"] }"
      
      service_url = request[:referer].presence || request.env['omniauth.origin'].presence || root_url
      session['destination'] = service_url
      redirect_to "https://cse-apps.unl.edu/cas/login?service=#{auth_cas_callback_url}&url=#{service_url}"

      #response.headers["referer"] = request.env['omniauth.origin'].presence || '/'
      #session['referer'] = request.env['omniauth.origin']
      #redirect_to users_sign_in_url
      #
      # THIS REDIRECT SEEMS TO _NOT_ CAUSE THE 404 ERROR FROM USING THE OPTIONS REQUEST DIRECTIVE
      #redirect_to "https://cse-apps.unl.edu/cas/login?service=http://localhost:3000/auth/cas/callback&url=#{destpath}"
      #redirect_to '/auth/cas', alert: "Sign in for access."
    else
      Rails.logger.info "@session_user exists in authenticate_user!"
      unless @session_user['authorized_as_user'].nil?
        if @session_user['authorized_as_user'].empty?
          Rails.logger.info "@session_user.authorized_as_user is empty.  "
        end
        Rails.logger.info "@session_user has authorized as user value set: #{@session_user['authorized_as_user']}"
        session[:authorized_as_user] = @session_user['authorized_as_user']
      else
        Rails.logger.info "@session_user.authorized_as_user is _NULL_, so no session. REMOVE @SESSION_USER !!!!!!!"
        @session_user = nil
      end
    end
  end

  def current_user
    # if @session_user.nil?
    #   @session_user = Identity.new(session)
    # end
    logger.info "DEBUG: current_user: [#{@session_user&.inspect}];"
    if @session_user.nil?
      if session['current_user']
        @session_user = session['current_user']
      end
    end
    @session_user
  end

  def current_user_logout
    if @session_user.nil? && session['current_user']
      @session_user = session['current_user']
    end
    if request.env['authenticity_token']
      logger.info "DEBUG: request.env has auth_token..."
    end
    @user_id = @session_user['user']['id'] if @session_user
    user = User.find(@user_id)&
    user.destroy! if user
    #@authorization = Authorization.find_by_user_id (@session_user['user']['login_id'])
    #@authorization.user.destroy!
    #@authorization.destroy! if @authorization
    session.destroy
      #Authorization.destroy(@session_user['user']['login_id'])
    #elsif @session_user && @session_user.login_id
    #  Authorization.find_by_uid(@session_user['user']['login_id']).destroy!
    #else
      #Rails.logger.info "ERROR: Authentication could not be removed..."
    #end
    @session_user = nil
  end

  private

  def user_signed_in?
    if @session_user.nil?
      if session['current_user']
        logger.info "DEBUG: user_signed_in has nil @session_user and session[curr_user] is present #{session['current_user']}"
        @session_user = session['current_user']
      end
    end
    return true if @session_user && @session_user['authorized_as_user'] && @session_user['user']['login_id']
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
        logger.info "DEBUG: app_ctrlr.set_curr_user: auth[uid]: '#{auth[:uid]}', provider: '#{auth[:provider]}'"
        session[:authorized_as_user] = auth[:uid]  # :uid = CSE LOGIN ID USED CAS SERVER
        session[:provider] = auth[:provider]
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
