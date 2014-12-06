# PasteRunner built by Tejas Manohar
# Released under the MIT License (mit-license.org)
# Open source on GitHub: http://github.com/tejas-manohar/pasterunner

# Gems
require 'json'
require 'sinatra'

configure :development do
  require 'pry'
  require 'sinatra/reloader'
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
  content_type :json
  { message: 'Hello World!' }.to_json
end