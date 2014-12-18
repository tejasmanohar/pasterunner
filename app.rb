# PasteRunner built by Tejas Manohar
# Released under the MIT License (mit-license.org)
# Open source on GitHub: http://github.com/tejasmanohar/pasterunner

# Gems
require 'ideone'
require 'http'
require 'json'
require 'sinatra'

configure :development do
  require 'pry'
  require 'sinatra/reloader'
end

configure do
  enable :protection
  ideone = Ideone.new(ENV['IDEONE_USERNAME'], ENV['IDEONE_PASSWORD'])
end

# Views
get '/' do
  erb :home
end

not_found do
  erb :not_found
end

# API
post '/run' do
  id = params[:url].split('/')[-1]
  response = JSON.parse(HTTP.get('https://api.github.com/gists/' + id))
  code = response['files'].values.map { |h| h['content'] }
  submission = ideone.create_submission(code, 17)
  output = ideone.submission_status
  content_type :json
  { stdout: output }.to_json
end
