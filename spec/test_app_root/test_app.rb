require 'canson'
require 'byebug'
class TestApp < Canson::Base

  get '/' do
    {results: 'hi'}
  end

  get '/ask' do |params|
    ask = params[:ask]
    {results: ask}
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
