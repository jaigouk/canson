# notes on grpc

### grpc.io says...

step1) proto files
```
// The greeting service definition.
service Greeter {
  // Sends a greeting
  rpc SayHello (HelloRequest) returns (HelloReply) {}
  // Sends another greeting
  rpc SayHelloAgain (HelloRequest) returns (HelloReply) {}
}
```

-[X] need to set proto folder
-[X] need to set input / output folder

step2) From the examples/ruby/ directory:
```
grpc_tools_ruby_protoc -I ../protos --ruby_out=lib --grpc_out=lib ../protos/helloworld.proto
#-> generates helloworld_pb.rb and helloworld_services_pb.rb
```

-[X] run the command

step3)
-[ ] dsl for client methods
-[ ] server side service codes should run separately 

https://io2015codelabs.appspot.com/codelabs/gRPC#1


gRPC ≠ REST. gRPC is also not object-oriented conceptually; the RPCs are more of functions than methods. In gRPC, all input parameters are via the messages

https://github.com/grpc/grpc/tree/7b104cd1c23a3e6ee3cb0809f39617ceda5e2575/examples/python/multiplex
An example showing two stubs sharing a channel and two servicers sharing a server.

https://github.com/soheilhy/cmux
cmux is a generic Go library to multiplex connections based on their payload. Using cmux, you can serve gRPC, SSH, HTTPS, HTTP, Go RPC, and pretty much any other protocol on the same TCP listener.

https://discuss.dgraph.io/t/golang-run-multiple-services-on-one-port-dgraph-blog/963
blog post about cmux example 


# handle registration of classes
    #
    # service is either a class that includes GRPC::GenericService and whose
    # #new function can be called without argument or any instance of such a
    # class.
    #
    # E.g, after
    #
    # class Divider
    #   include GRPC::GenericService
    #   rpc :div DivArgs, DivReply    # single request, single response
    #   def initialize(optional_arg='default option') # no args
    #     ...
    #   end
    #
    # srv = GRPC::RpcServer.new(...)
    #
    # # Either of these works
    #
    # srv.handle(Divider)
    #
    # # or
    #
    # srv.handle(Divider.new('replace optional arg'))
    #
    # It raises RuntimeError:
    # - if service is not valid service class or object
    # - its handler methods are already registered
    # - if the server is already running
    #
    # @param service [Object|Class] a service class or object as described
    #        above







# ETC

### gRPC AND H2
https://github.com/grpc/grpc/blob/master/doc/PROTOCOL-WEB.md

### Load Balancing
https://github.com/grpc/grpc/blob/master/doc/load-balancing.md

https://github.com/grpc/grpc/blob/master/doc/PROTOCOL-HTTP2.md

# HTTP to gRPC Status Code Mapping
https://github.com/grpc/grpc/blob/master/doc/statuscodes.md

Since intermediaries are a common part of HTTP infrastructure some responses to
gRPC requests may be received that do not include the grpc-status header. In
some cases mapping error codes from an intermediary allows the gRPC client to
behave more appropriately to the error situation without overloading the
semantics of either error code.

This table is to be used _only_ for clients that received a response that did
not include grpc-status. If grpc-status was provided, it _must_ be used. Servers
_must not_ use this table to determine an HTTP status code to use; the mappings
are neither symmetric nor 1-to-1.

| HTTP Status Code           | gRPC Status Code   |
|----------------------------|--------------------|
| 400 Bad Request            | INTERNAL           |
| 401 Unauthorized           | UNAUTHENTICATED    |
| 403 Forbidden              | PERMISSION\_DENIED |
| 404 Not Found              | UNIMPLEMENTED      |
| 429 Too Many Requests      | UNAVAILABLE        |
| 502 Bad Gateway            | UNAVAILABLE        |
| 503 Service Unavailable    | UNAVAILABLE        |
| 504 Gateway Timeout        | UNAVAILABLE        |
| _All other codes_          | UNKNOWN            |
