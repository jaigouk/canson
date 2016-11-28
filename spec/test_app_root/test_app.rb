require 'canson'

class TestApp < Canson::Base
  def self.print_out
    puts 'hijack'
  end

  on_open do
    puts "Connected"
  end

  on_close do |params|
    puts "Bye Bye... #{params[:count]} connections left..."
  end

  on_shutdown do
    write 'The server is shutting down, goodbye.'
  end

  on_message do |params|
    data = params[:data]
    ws = params[:ws]
    nickname = params[:nickname]
    tmp = "#{nickname}: #{data}"
    ws.write tmp
    ws.each { |h| h.write tmp }
    puts '================================'
    puts "got message: #{data} encoded as #{data.encoding}"
    puts "broadcasting #{tmp.bytesize} bytes with encoding #{tmp.encoding}"
    puts '================================'
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
