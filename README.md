# Canson

small rack based framework that can run websocket. 20K connections can be handled

## Run the example chat app

```
cd spec/test_app_root
bundle install
bundler exec iodine -p 3000 -t 16 -w 4
```

open localhost:3000 in browser

## Example app

in `spec/test_app_root`

```
require 'canson'
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

   on_open do
    puts '================================'
    puts 'We have a websocket connection'
    puts '================================'
  end

  on_close do
    puts "Bye Bye... #{count} connections left..."
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
end
```

```
require './test_app.rb'
run TestApp.new
```


## Usage

Given the following piece of ruby code:

```ruby
# config.ru

require "canson"

get "/index" do
  { results: [1, 2, 3] }
end
```

> The server is run via `bundle exec rackup --port 3000`.

When requested with `curl http://localhost:3000/bla -i`, it should return:

```
HTTP/1.1 200 OK
Content-Type: application/json

{"results": [1, 2, 3]}
```

Given the following piece of ruby code:

```ruby
# config.ru

require "trialday"

get "/bla" do
  { results: [1, 2, 3] }
end

post "/bla" do |params|
  name = params[:name]

  { name: name }
end
```

When requested with `curl http://localhost:3000/index -i`, it should return:

```
HTTP/1.1 200 OK
Content-Type: application/json

{"results": [1, 2, 3]}
```

When requested with `curl -XPOST http://localhost:3000/bla -i -H "Content-Type: application/json" -d '{"name": "Mario"}'`, it should return:

```
HTTP/1.1 200 OK
Content-Type: application/json

{"name": "Mario"}
```

