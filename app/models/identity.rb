#
# Container for logged in user identity
class Identity

  @user
  @authorized_as_user

  def identity
    return self
  end

  def initialize(session)
    @user = nil
    @authorized_as_user = nil
    if session[:authorized_as_user].nil?
      logger.info "ERROR: session[authorized_as_user] not in session passed to Identity.initialize()"
    else
      @authorized_as_user = session[:authorized_as_user]
      @user = User.find(@authorized_as_user)
    end
    # TODO: APPLY ANY PRIVILEGES AND IMPERSONATIONS
  end

end