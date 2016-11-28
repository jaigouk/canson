
## Parsing

https://github.com/sinatra/mustermann
https://github.com/tmm1/http_parser.rb
https://github.com/ngauthier/tubesock

## Streaming

https://rosenfeld.herokuapp.com/en/articles/ruby-rails/2016-07-02-the-sad-state-of-streaming-in-ruby-web-applications
Each request thread (or process) has access to a "response" object that accepts a "write" call that goes directly to the socket's output (or after a "flush" call).
It would be awesome if Ruby web applications had the option to use a more flexible API, more friendly to streamed responses, including SSE and websockets. Hijacking currently seems to be considered a second-class citizen since they are usually ignored by major web frameworks like Rails itself.

https://bowild.wordpress.com/2016/07/31/the-dark-side-of-the-rack/
what if everything we had to do to upgrade from HTTP to Websockets was something like this env[upgrade.websockets] = MyCallbacks.new(env)…?

We can unify the IO polling for all IO objects (HTTP, Websocket, no need for hijack). This is bigger then you think.
We can parse websocket data before entering the GIL, winning some of our concurrency back. This also means we can better utilize multi-core CPUs.

We don’t need to know anything about network programming – let the people programming servers do what they do best and let the people who write web applications focus on their application logic.
https://gist.github.com/boazsegev/1466442c913a8dd4271178cab9d98a27
https://github.com/boazsegev/iodine

http://rubykaigi.org/2015/presentations/tenderlove

https://github.com/SamSaffron/message_bus

rack hijack
https://github.com/ngauthier/tubesock

https://bowild.wordpress.com/2016/07/31/the-dark-side-of-the-rack/

https://blog.heroku.com/real_time_rails_implementing_websockets_in_rails_5_with_action_cable


https://blog.heroku.com/real_time_rails_implementing_websockets_in_rails_5_with_action_cable


https://klibert.pl/statics/python-and-elixir/#/

https://www.reddit.com/r/ruby/comments/4r9alo/the_sad_state_of_streaming_support_in_ruby_web/

If your servers were implementing HTTP/2, then hijacking the IO would break the protocol and (hopefully) terminate the connection with no data being received.
HTTP/2 is a binary protocol with packet headers and footer. If the hijacked IO doesn't write the data as HTTP/2 packets and sends the end of stream flag upon completion, then the receiving party will simply assume the data is garbage and (if implementing the standard correctly) will disconnect.
This is the reason I though hijacking is limited and approaching an end-of-life cycle for HTTP requests (will soon be impossible). It's only possible long term implementation is HTTP upgrade requests which usually means a long-lived connection is being established with either Websockets or HTTP/2 (although other protocols can also be used with the technique).

https://gist.github.com/TiagoCardoso1983/591d48cfde04219f801fa7fd7966571c

For http2, the same above stands, with a few add-ons:
Ruby's openssl is (at least, it was) missing some bugfixes for ALPN negotiation (is it still valid?).

Ruby is currently missing an optimized parser for http2 requests (not a big hinderance, as there's an http2 pure ruby gem around).
http2-to-http1 on the web server is seemingly "good enough".
http2 protocol is only a big gain if one is using an evented application server, as the big thing over there is the frame multiplexing.

So, we have thin and reel. Both of them use C-written event loops (reel uses libev), which means we're out of ruby core, and are not widely used (correct me if I'm wrong, but is reel compatible with most available middlewares? Is it running rails for anyone?).

rack needs to die and be born again. event-based middlewares, #call(request, response) instead of #call(env), a proper stream object with less socket-y semantics, the rack hijack hack won't stand.

nio4r (celluloid-io/reel) looks much better, but ships with a patched version of libev because no-ruby-core-GIL-API). It brings with it the libev's "problems", which are no Windows support or no support for not-network file descriptors (file, pipes) (not really a problem when there is no competition though).

### grpc

* stackoverflow

http://stackoverflow.com/questions/35065875/how-to-bring-a-grpc-defined-api-to-the-web-browser

We want to build a Javascript/HTML gui for our gRPC-microservices. Since gRPC is not supported on the browser side, we thought of using web-sockets to connect to a node.js server, which calls the target service via grpc. We struggle to find an elegant solution to do this. Especially, since we use gRPC streams to push events between our micro-services. It seems that we need a second RPC system, just to communicate between the front end and the node.js server. This seems to be a lot of overhead and additional code that must be maintained.

Does anyone have experience doing something like this or has an idea how this could be solved?

https://github.com/tmc/grpc-websocket-proxy sounds like it may meet your needs. This translates json over web sockets to grpc (layer on top of grpc-gateway).


https://coreos.com/blog/gRPC-protobufs-swagger.html

One of the key reasons we chose gRPC is because it uses HTTP/2, enabling applications to present both a HTTP 1.1 REST+JSON API and an efficient gRPC interface on a single TCP port. This gives developers compatibility with the REST web ecosystem while advancing a new, high-efficiency RPC protocol. With Go 1.6 recently released, Go ships with a stable net/http2 package by default.


https://github.com/grpc-ecosystem/grpc-gateway

https://github.com/ruby-concurrency/concurrent-ruby/blob/master/doc/channel.md

https://github.com/paralin/grpc-bus
