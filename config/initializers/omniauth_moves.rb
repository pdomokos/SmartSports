Rails.application.config.middleware.use OmniAuth::Builder do
  provider :moves, ENV['MOVES_KEY'], ENV['MOVES_SECRET']
  provider :withings, ENV['WITHINGS_KEY'], ENV['WITHINGS_SECRET']
end