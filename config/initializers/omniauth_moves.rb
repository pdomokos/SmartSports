Rails.application.config.middleware.use OmniAuth::Builder do
  if defined? APP_CONFIG
    provider :moves, APP_CONFIG['MOVES_KEY'], APP_CONFIG['MOVES_SECRET']
    provider :withings, APP_CONFIG['WITHINGS_KEY'], APP_CONFIG['WITHINGS_SECRET']
    provider :fitbit, APP_CONFIG['FITBIT_KEY'], APP_CONFIG['FITBIT_SECRET']
  else
    provider :moves, ENV['MOVES_KEY'], ENV['MOVES_SECRET']
    provider :withings, ENV['WITHINGS_KEY'], ENV['WITHINGS_SECRET']
    provider :fitbit, ENV['FITBIT_KEY'], ENV['FITBIT_SECRET']
  end
end
