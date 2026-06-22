# Developing — area_calculator gRPC example

## Prerequisites

Install the Protobuf compiler and plugins:

1. `gem install grpc`
2. `gem install grpc-tools`
3. `pact-plugin-cli -y install https://github.com/pactflow/pact-protobuf-plugin/releases/latest`

## Regenerating stubs from the proto file

```sh
grpc_tools_ruby_protoc -I ../proto --ruby_out=lib --grpc_out=lib ../proto/area_calculator.proto
```

Or using `protoc` directly (requires Go plugins installed):

```sh
protoc --go_out=. --go-grpc_out=. --proto_path ../proto ../proto/area_calculator.proto
protoc --ruby_out=../lib --grpc_out=../lib ../proto/area_calculator.proto
```

## Running the demo

```sh
# Terminal 1
ruby area_calculator_provider.rb

# Terminal 2
bundle exec rspec spec/pactffi_create_plugin_pact_spec.rb
```

Or via the repo root:

```sh
make grpc
```

## References

- <https://grpc.io/docs/languages/ruby/quickstart/>
- <https://www.varvet.com/blog/advanced-topics-in-ruby-ffi/>
