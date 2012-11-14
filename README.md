# Sanford Protocol

This gem is the ruby implementation for Sanford's communication protocol. It provides Sanford's request and response objects along with an IO object for reading and writing messages.

## Protocol

**Version**: 1

Sanford communicates using a stream of bytes and it converts all data into it's binary format to facilitate this. All Sanford communication falls into the following format:

```
# as a stream of bytes
[ size, protocol_version, message ]
```

The `size` section is always 4 bytes, the `protocol_version` is 1 byte and the message size is encoded in the previous `size` section. The `protocol_version` is used to verify the client and server are using the same version of Sanford's protocol. If they aren't then unexpected errors could occur. The `message` contains either a serialized request or response. All messages are encoded using [BSON](http://bsonspec.org/) and thus are ruby hashes when decoded.

### Request

A request is made up of 3 parts: the service name, the service version and the params.

* **service name** - (string) The service that the request is calling. This is used with the service version to find a matching service handler. If one isn't found, then the request is rejected.
* **service version** - (string) The version of the service that the request is calling. This is used with the service name to find a matching service handler. If one isn't found, then the request is rejected.
* **params** - Parameters to call the service with. This can be any BSON serializable object.

The service name, version and params are always required. A BSON request should look like:

```ruby
{ 'name':     'some_service',
  'version':  'v1'
  'params':   'something'
}
```

### Response

A response is made up of 2 parts: the status and the result.

* **status** - (tuple) A number that determines whether the request was successful or not and a message that includes details about the status. See the "Protocol - Status Codes" section further down for a list of all the possible values.
* **result** - Result of running the service. This can be any BSON serializable object and won't be set if the request wasn't successful.

A response should always contain a status, but the result is optional. A BSON response should look like:

```ruby
{ 'status': [ 200, 'The request was successful.' ]
  'result': true
}
```

#### Status Codes

This is the list of predefined status codes. In addition to using these, a service can return custom status codes, but they should use a number greater than or equal to 600 to avoid collisions with Sanford's defined status codes. The list contains both the integer value and the name of the status code along with a description of what each code is intended for:

* `200` - `success` - The request was successful.
* `400` - `bad_request` - The request couldn't be read. This is usually because it was not formed correctly. This can mean a number of things, check the response message for details:
  * The message size couldn't be read or was invalid.
  * The protocol version couldn't be read or didn't match the servers.
  * The message body couldn't be deserialized.
* `404` - `not_found` - The service name didn't match a configured service.
* `500` - `error` - An error occurred when calling the service. The message attribute of the response should be used to get more details.

## Usage

The Sanford Protocol gem provides the mixin `Sanford::Protocol` that defines helper methods for communicating with a Sanford server. To use it, mix it in to any object:

```ruby
class MyObject
  include Sanford::Protocol
end

my_object = MyObject.new
message = { 'something' => true }
serialized_message = my_object.serialize_message(message)
my_object.deserialize_message(serialized_message)
```

Though this can be convenient, there are additional classes included in this gem that can provide more features.

### Connection

Typically, when working with Sanford's protocol, you'll be using sockets. In this case, the `Sanford::Protocol::Connection` class can be used:

```ruby
connection = Sanford::Protocol::Connection.new(socket)
message = connection.read
# process the message, generate new message
connection.write(new_message)
```

The first thing to note is that the connection class needs to be manually required. Secondly, the `Sanford::Protocol::Connection` class takes a socket and messages can be read and written to it. Though messages can be use directly when read or built manually, it's recommended to use the `Sanford::Protocol::Request` and `Sanford::Protocol::Response` objects instead.

### Requests And Responses

Requests and responses can be built using messages that are returned from the `Sanford::Protocol::Connection` class:

```ruby
# on a server, read off requests, write a response
message = connection.read
request = Sanford::Protocol::Request.parse(message)
# process the request
response = Sanford::Protocol::Response.new(status, result)
connection.write(response.to_message)

# on a client, write a request and then read off a resposne
request = Sanford::Protocol::Request.new(name, version, params)
connection.write(request.to_message)
message = connection.read
response = Sanford::Protocol::Response.parse(message)
```

## Test Helpers

```ruby
# fake a socket with some incoming binary
socket = FakeSocket.new(msg_binary_string)
connection = Sanford::Protocol::Connection.new(socket)
msg_data = connection.read

# write some binary to that fake socket and verify it
connection.write(msg_data)
puts socket.out # => msg binary string

# create a socket with an incoming request and verify the request
socket   = FakeSocket.with_request(*request_params)
msg_data = Sanford::Protocol::Connection.new(socket).read
request  = Sanford::Protocol::Request.parse(msg_data)
```

A `FakeSocket` test helper class and an associated `Test::Helpers` module are provided to help test receiving and sending Sanford::Protocol messages.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
