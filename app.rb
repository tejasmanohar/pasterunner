# PasteRunner built by Tejas Manohar
# Released under the MIT License (mit-license.org)
# Open source on GitHub: http://github.com/tejasmanohar/pasterunner


# Gems
require 'nokogiri'
require 'net/http'
require 'faraday'
require 'json'
require 'sinatra'


# Sinatra Settings
configure do
  enable :protection
  ServiceURI = URI('https://eval.in/')
end


# Helpers
helpers do
  
  def get_gist_code(id)
    uri = URI('https://api.github.com/gists/' + id)
    res = Net::HTTP.get_response(uri)
    if res.is_a?(Net::HTTPSuccess)
      data = JSON.parse(res.body)
      code = data['files'].values.map { |h| h['content'] }
    else
      raise CommunicationError, res
    end
  end

  def eval_in(snippet)
    result = Net::HTTP.post_form(
      ServiceURI,
     "utf8" => "λ",
     "code" => snippet,
     "execute" => "on",
     "lang" => "ruby/mri-2.1",
     "input" => ""
    )
    if result.is_a? Net::HTTPFound
      location = URI(result['location'])
      location.scheme = 'https'
      location.port = 443

      body = Nokogiri(Net::HTTP.get(location))

      if output_title = body.at_xpath("*//h2[text()='Program Output']")
        output = output_title.next_element.text
      end
    else
      raise CommunicationError, result
    end
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
  code = get_gist_code(id)
  eval_in code
end
