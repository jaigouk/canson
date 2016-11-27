require 'spec_helper'

describe "TestApp" do
  include Rack::Test::Methods

  def app
    TestApp.new
  end

   describe 'get /' do
    it 'returns result and header' do
      get '/'
      res = JSON.parse(last_response.body)
      last_response.ok?.must_equal true
      res['results'].must_equal 'hi'
      header = last_response.header
      header['Content-Type'].must_equal 'application/json'
    end
  end

  describe 'get /ask' do
    it 'accepts params' do
      get '/ask', {ask: 'jedi'}.to_json
      res = JSON.parse(last_response.body)
      last_response.ok?.must_equal true
      res['results'].must_equal 'jedi'
      header = last_response.header
      header['Content-Type'].must_equal 'application/json'
    end
  end

  describe 'get /index' do
    it 'returns result and header' do
      get '/index'
      res = JSON.parse(last_response.body)
      last_response.ok?.must_equal true
      res['results'].must_equal [1, 2, 3]
      header = last_response.header
      header['Content-Type'].must_equal 'application/json'
    end
  end

  describe 'get /bla' do
    it 'returns result and header' do
      get '/bla'
      last_response.ok?.must_equal true
      res = JSON.parse(last_response.body)
      res['name'].must_equal 'James'
      header = last_response.header
      header['Content-Type'].must_equal 'application/json'
    end
  end

  describe 'post /bla' do
    it 'returns results and header' do
      post '/bla', {name: 'Skywalker'}.to_json
      last_response.ok?.must_equal true
      res = JSON.parse(last_response.body)
      res['name'].must_equal 'Skywalker'
      header = last_response.header
      header['Content-Type'].must_equal 'application/json'
    end

    it 'returns nothing if there is no name in param' do
      post '/bla', {name: ''}.to_json
      last_response.ok?.must_equal true
      res = JSON.parse(last_response.body)
      res['name'].must_equal ''
    end

    it 'returns nothing if there is no matching param' do
      post '/bla', {foo: ''}.to_json
      last_response.ok?.must_equal true
      res = JSON.parse(last_response.body)
      res['name'].must_equal nil
    end
  end
end
