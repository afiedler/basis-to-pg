require 'faraday'
require 'dotenv'
require 'http-cookie'

Dotenv.load

conn = Faraday.new(:url => 'https://app.mybasis.com') do |faraday|
  faraday.request  :url_encoded             # form-encode POST params
  faraday.response :logger                  # log requests to STDOUT
  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
end



res = conn.post '/login', {
    username: ENV['USERNAME'],
    password: ENV['PASSWORD']
  }

cookie = HTTP::Cookie.parse(res.headers['set-cookie'], 'https://app.mybasis.com')
access_token = cookie.to_a.find { |s| s.name == 'access_token' }.value rescue nil

if access_token.nil?
  raise 'Unable to login to app.mybasis.com, access_token not found in cookie'
end

conn = Faraday.new(url: 'https://app.mybasis.com') do |faraday|
  faraday.response :logger
  faraday.headers['X-Basis-Authorization'] = 'OAuth ' + access_token
  faraday.adapter Faraday.default_adapter
end

res = conn.get '/api/v1/metricsday/me', {
  day: '2015-11-01',
  padding: 0,
  heartrate: 'true',
  steps: 'true',
  calories: 'true',
  gsr: 'true',
  skin_temp: 'true',
  air_temp: 'true',
  bodystates: 'true'
}

puts res.body
