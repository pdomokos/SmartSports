Rails.application.config.middleware.use OmniAuth::Builder do
  if defined? APP_CONFIG
    provider :moves, CONNECTION_CONFIG['MOVES_KEY'], CONNECTION_CONFIG['MOVES_SECRET']
    provider :withings, CONNECTION_CONFIG['WITHINGS_KEY'], CONNECTION_CONFIG['WITHINGS_SECRET']
    provider :fitbit, CONNECTION_CONFIG['FITBIT_KEY'], CONNECTION_CONFIG['FITBIT_SECRET']
    provider :google_oauth2, CONNECTION_CONFIG["GOOGLE_CLIENT_ID"], CONNECTION_CONFIG["GOOGLE_CLIENT_SECRET"], {
      :scope => 'email,profile,https://www.googleapis.com/auth/fitness.activity.read',
      :prompt => 'consent'
    }
  else
    provider :moves, ENV['MOVES_KEY'], ENV['MOVES_SECRET']
    provider :withings, ENV['WITHINGS_KEY'], ENV['WITHINGS_SECRET']
    provider :fitbit, ENV['FITBIT_KEY'], ENV['FITBIT_SECRET']
    provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"], {
      :scope => 'email,profile,https://www.googleapis.com/auth/fitness.activity.read',
      :prompt => 'consent'
    }
  end
end
