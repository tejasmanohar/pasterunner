# PasteRunner built by Tejas Manohar
# Released under the MIT License (mit-license.org)
# Open source on GitHub: http://github.com/tejasmanohar/pasterunner


# Gems
require 'nokogiri'
require 'net/http'
require 'json'
require 'sinatra'


# Sinatra Settings
configure do
  enable :protection
  ServiceURI = URI('https://eval.in/')
end


# Helpers
helpers do
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
        first_line = (output.each_line.first || "").chomp
        needs_ellipsis = output.each_line.count > 1 ||
          first_line.length > MaxLength

        "#{first_line[0, MaxLength]}#{'...' if needs_ellipsis} "\
        "(#{location})"
      else
        raise FormatError, 'could not find program output'
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
  res = Faraday.get('https://api.github.com/gists/' + id)
  data = JSON.parse(res.body)
  code = data['files'].values.map { |h| h['content'] }
  p code[0]
  p eval_in(code[0])
end
