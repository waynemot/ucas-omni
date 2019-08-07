#
# Container for logged in user identity
class Identity

  #@user
  #@authorized_as_user

  def identity
    return self
  end

  def user
    return @user
  end

  def authorized_as_user
    return @authorized_as_user
  end

  def initialize(session)
    Rails.logger.info "DEBUG: Identity.init() start..."
    @user = nil
    @authorized_as_user = nil
    if session[:authorized_as_user].nil?
      Rails.logger.info "ERROR: session[authorized_as_user] not in session passed to Identity.initialize()"
    else
      Rails.logger.info "DEBUG: set @authorized_as_user and @user..."
      @authorized_as_user = session[:authorized_as_user]
      Rails.logger.info "DEBUG: @authorized_as_user: #{@authorized_as_user}"
      @user = User.find_by_login_id(@authorized_as_user)
    end
    # TODO: APPLY ANY PRIVILEGES AND IMPERSONATIONS
  end

  def empty?
    if  @user.nil? || @user.empty? || @authorized_as_user.nil? || @authorized_as_user.empty?
      true
    end
  end

end