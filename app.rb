# PasteRunner built by Tejas Manohar
# Released under the MIT License (mit-license.org)
# Open source on GitHub: http://github.com/tejas-manohar/pasterunner

require 'sinatra'

configure :development do
  require 'pry'
  require 'sinatra/reloader'
end
