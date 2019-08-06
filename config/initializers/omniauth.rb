OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas,
           url: 'https://cse-apps.unl.edu/cas',
           #ssl: true,
           callback_url: '/callbacks/cas',
           host: "cse-asarma-16.unl.edu:3000"
           # host: 'cse-apps.unl.edu'
           #service_validate_url: '/cas',
           #logout_url: '/cas/logout',
           #fetch_raw_info: Proc.new { Hash.new },
           #login_url: '/cas/login'
           #uid_field: 'username'
end
