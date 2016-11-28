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
update server / client rb files
