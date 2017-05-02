require_relative 'boot'

require 'rails/all'

require 'faultline/rack'
Faultline.configure do |c|
  c.project = 'faultline-rack'
  c.api_key = 'xxxxxxxxxxxxxXXXXXXxxxxxx'
  c.endpoint = 'https://xxxxxxxxxxx.execute-api.ap-northeast-1.amazonaws.com/v0'
  c.notifications = [
    {
      type: 'slack',
      endpoint: 'https://hooks.slack.com/services/XXXXXXXXXXX/B2RAD9423/WC2uTs3MyGldZvieAtAA7gQq',
      channel: '#random',
      username: 'faultline-notify',
      notifyInterval: 1,
      threshold: 1,
      timezone: 'Asia/Tokyo'
    }
  ]
end

Bundler.require(*Rails.groups)

module FaultlineRack
  class Application < Rails::Application
    config.load_defaults 5.1
    config.middleware.use Faultline::Rack::Middleware
  end
end
