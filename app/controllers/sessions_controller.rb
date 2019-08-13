class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[create, logout]
  def new
    #redirect_to "https://cse-apps.unl.edu/cas/login?service=http://localhost:3000/auth/cas/callback&gateway=true"
    logger.info "DEBUG: sess_ctrlr.new() redirect to /auth/cas"
    redirect_to '/auth/cas'
  end

  def create
    logger.info "DEBUG: SessionCtrlr.create() Start..."
    auth_hash = request.env['omniauth.auth']
    logger.info "DEBUG: session omniauth.auth auth_hash: #{auth_hash.inspect}"
    @authorization = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash['uid'])
    if @authorization
      logger.info "DEBUG: OK we found the provider and hash in the Authorization table"
      logger.info "DEBUG: @authorization passed: #{@authorization.inspect}"
      if session[:user_id]
        if @authorization.user_id == session[:user_id]
          # REINIT EXISTING SESSION, AUTH & USER ALREADY EXIST
          logger.info "DEBUG: Session user_id is Authorization user_id, Already Known Session/Authorization"
          redirect_to request.env['omniauth.origin'].presence || root_url
        else
          logger.info "ERROR: Session user != @authorization user -> Mismatching CAS/Application identities"
          # TODO: ADD CODE TO HANDLE HAVE AUTHORIZATION W/O SESSION
          if @authorization.user_id.nil?
            logger.info "DEBUG: @authorization.user_id is NULL..."
          end
        end
      end
      set_current_user( @authorization, session )
      logger.info "DEBUG: after set_current_user: current_user is now: #{current_user.inspect}"
      logger.info "DEBUG: REQUEST[omniauth.origin]: #{request.env['omniauth.origin']}"
      logger.info "DEBUG: SESSION[destination]: #{session["destination"]}"
      session['current_user'] = current_user
      if request.env['omniauth.origin']
        redirect_to request.env['omniauth.origin'], notice: "#{current_user.authorized_as_user} now logged in..."
      elsif session['destination'].present?
        redirect_to session['destination'], notice: "#{current_user.authorized_as_user} now logged in..."
      else
        logger.info "DEBUG: session[dest] unset, redirecting to -> omniauth.origin or root_url path..."
        redirect_to request.env['omniauth.origin'].presence || root_url, notice: "#{current_user.authorized_as_user} now logged in..."
      end
    else
      logger.info "DEBUG: user not found via authorization, if valid create new user & build user.authorizations"
      if auth_hash['uid']
        logger.info "DEBUG: auth_hash[uid]: #{auth_hash['uid']}"
      else
        logger.info "DEBUG: request.env[omniauth.auth] false?!?!?"
      end
      if auth_hash['omniauth.params']
        logger.info "DEBUG: env.omninauth.params: #{auth_hash['omniauth.params']}"
      else
        logger.info "DEBUG: request.env[omniauth.params] false?!?!?"
      end
      user = User.new name: auth_hash['extra']['user'], login_id: auth_hash['uid']
      user.authorizations.build provider: auth_hash['provider'], uid: auth_hash['uid']
      user.save!
      logger.info "DEBUG: create user with CAS credentials done for user #{user.id}"
      set_current_user(Authorization.find_by_provider_and_uid(auth_hash['provider'], auth_hash['uid']), session)

      if request.env['omniauth.origin']
        logger.info "DEBUG: Redirect to omniauth.origin specified: #{request.env['omniauth.origin']}"
        redirect_to request.env['omniauth.origin'], method: :get
      elsif session['destination']
        redirect_to session['destination'], method: :get
      else
        logger.info "DEBUG: omniauth.ORIGIN UNSET in request.env?? #{request.env['omniauth.origin'].inspect}"
        redirect_to root_url
      end
    end
  end

  def signin
    logger.info "DEBUG: sess_ctrlr.signin() traversed. params: #{params.inspect}"
    # TODO: This may not be the proper way to access the cas server, and the service path needs composing for production
    # composing the service and url
    redirect_to "https://cse-apps.unl.edu/cas/login?service=http://localhost:3000/auth/cas/callback?url=http://localhost:3000/"
  end

  def logout
    logger.info "DEBUG: sessions.logout() path traversed..."
    current_user_logout
    redirect_to "https://cse-apps.unl.edu/cas/logout?destination=#{root_url}&gateway=true", method: :delete
    #redirect_to root_url
  end


  def failure
    #redirect_to login_url
    redirect_to root_url, alert: "CAS OmniAuth Authentication error: #{params[:message].humanize}"
  end
end
