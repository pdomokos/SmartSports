Rails.application.config.middleware.use OmniAuth::Builder do
  provider :moves, APP_CONFIG['MOVES_KEY'], APP_CONFIG['MOVES_SECRET']
  provider :withings, APP_CONFIG['WITHINGS_KEY'], APP_CONFIG['WITHINGS_SECRET']
  provider :fitbit, APP_CONFIG['FITBIT_KEY'], APP_CONFIG['FITBIT_SECRET']
end