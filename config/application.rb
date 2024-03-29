require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
module UnlcasOmniauth
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.session_store :cookie_store, key: '_unlcas_session'
    # config.session_store :active_record_store, :key => '_unlcasomni_session'
	config.middleware.use ActionDispatch::Cookies
	config.middleware.use ActionDispatch::Session::CookieStore, config.session_options
  end

  def current_user

  end
end
