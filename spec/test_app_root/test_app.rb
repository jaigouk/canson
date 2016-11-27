require 'canson'
require 'byebug'
class TestApp < Canson::Base

  def self.print_out
    puts 'hijack'
  end

  get '/' do
    print_out
    {results: 'hi'}
  end

  get '/ask' do |params|
    name = params[:name]
    {results: name}
  end

  get '/index' do
    { results: [1, 2, 3] }
  end

  post '/bla' do |params|
    name = params[:name]

    { name: name }
  end

  get '/bla' do
    { name: 'James' }
  end
end
