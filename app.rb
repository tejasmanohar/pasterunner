# PasteRunner built by Tejas Manohar
# Released under the MIT License (mit-license.org)
# Open source on GitHub: http://github.com/tejasmanohar/pasterunner


# Gems
require 'faraday'
require 'json'
require 'sinatra'


# Sinatra Settings
configure do
  enable :protection
end


# Helpers
helpers do
  def eval_in(snippet)
    res = Faraday.post('https://eval.in/', { :utf8 => 'λ', :code => snippet, :lang => 'ruby/mri-2.1' })
    return res.body
  end
end


# Views
get '/' do
  erb :home
end

not_found do
  erb :not_found
end


# API
post '/exec' do
  id = params[:url].split('/')[-1]
  res = Faraday.get('https://api.github.com/gists/' + id)
  data = JSON.parse(res.body)
  code = data['files'].values.map { |h| h['content'] }

  p eval_in(code)
end
