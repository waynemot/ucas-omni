class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  def new
  end

  def create
    logger.info "DEBUG: SessionCtrlr.create() traversed request keys: #{request.env.keys}"
    auth_hash = request.env['omniauth.auth']
    @authorization = Authorization.find_by_provider_and_uid(auth_hash["provider"], auth_hash['uid'])
    if @authorization
			render text: "OK we found the provider and hash in the Authorization table"
		else
			user = User.new name: auth_hash['user_info']['name'], login_id: auth_hash['user_info']['login_id']
			user.authorizations.build provider: auth_hash['provider'], uid: auth_hash['uid']
			user.save!
			render text: "SessionsCtrlr.create(): Made a new user object with name: #{user.name} and login_id #{user.login_id}"
    end
    #render text: auth_hash.inspect
  end


  def failure
    redirect_to root_url, alert: "CAS OmniAuth Authentication error: #{params[:message].humanize}"
  end
end
