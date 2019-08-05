class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  def new
  end

  def create
    logger.info "DEBUG: SessionCtrlr.create() traversed request keys: #{request.env.keys}"
    auth_hash = request.env['omniauth.auth']
    logger.info "DEBUG: auth_hash: #{auth_hash.inspect}"
    @authorization = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash['uid'])
    if @authorization
      logger.info "OK we found the provider and hash in the Authorization table"
      current_user @authorization
    else
      logger.info "DEBUG: user not found via authorization. Apply authorization returned to user in omniauth.params"
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
      current_user Authorization.find_by_provider_and_uid(auth_hash['provider'], auth_hash['uid'])
      #render text: "SessionsCtrlr.create(): Made a new user object with name: #{user.name} and login_id #{user.login_id}"
      if request.env['omniauth.origin']
        logger.info "DEBUG: Redirect to omniauth.origin specified: #{request.env['omniauth.origin']}"
        redirect_to request.env['omniauth.origin'], method: :get
      else
        logger.info "DEBUG: omniauth.origin unset in request.env?? #{request.env['omniauth.origin'].inspect}"
        redirect_to root_url
      end
    end
  end

  def logout
    logger.info "DEBUG: sessions.logout() path traversed..."
    redirect_to 'cse-apps.unl.edu/cas/logout'
  end


  def failure
    redirect_to root_url, alert: "CAS OmniAuth Authentication error: #{params[:message].humanize}"
  end
end
