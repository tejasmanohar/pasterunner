# PasteRunner built by Tejas Manohar
# Released under the MIT License (mit-license.org)
# Open source on GitHub: http://github.com/tejasmanohar/pasterunner


# Gems
require 'nokogiri'
require 'http'
require 'json'
require 'sinatra'


# Sinatra Settings
configure do
  enable :protection
  set :server, 'webrick'
end


# Helpers
helpers do
  
  def get_gist_code(id)
    result = HTTP.with_headers(:'User-Agent' => 'tejasmanohar/pasterunner')
                 .get('https://api.github.com/gists/' + id)
    data = JSON.parse result.body.to_s
    code = data['files'].values.map { |h| h['content'] }
  end

  def eval_in(code, language)
    result = HTTP.with_headers(:'User-Agent' => 'tejasmanohar/pasterunner')
                 .post('https://eval.in/', :form => {
                   :utf8 => 'λ',
                   :code => code,
                   :execute => 'on',
                   :lang => language
                 })
    location = result['location']

    data = JSON.parse HTTP.get(location + '.json')

    data['output']

  end

end


# Views
get '/' do
  erb :home
end

get '/about' do
  erb :about
end

not_found do
  erb :not_found
end


# API
post '/exec' do
  id = params[:url].split('/')[-1]
  code = get_gist_code(id)
  @output = eval_in code, params[:language]
  erb :output
end
