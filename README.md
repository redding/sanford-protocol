# Sanford Protocol

Ruby implementation of Sanford TCP communication protocol.

## The Protocol

**Version**: `2`

Sanford communicates using binary encoded messages.  Sanford messages are two headers and a body:

```
|------ 1B -------|------ 4B -------|---- (Body Size)B ----|
| (packed header) | (packed header) | (BSON binary string) |
|     Version     |    Body Size    |         Body         |
|-----------------|-----------------|----------------------|
```

### Version

The first header represents the protocol version in use.  It is a 1 byte unsigned integer and exists to ensure both the client and the server are talking the same protocol.

### Body Size

The second header represents the size of the message's body.  It is a 4 byte unsigned integer and tells the receiver how many bytes to read to receive the body.

### Body

The Body is the content of the message.  It is a [BSON](http://bsonspec.org/) encoded binary string that decodes to a ruby hash.  Since the size of the body is encoded as a 4 byte (32 bit) unsigned integer, there is a size limit for body data (`(2 ** 32) - 1` or `4,294,967,295` or `~4GB`).

## Request

A request is made up of 2 required parts: the name, and the params.

* **name**   - (string) name of the requested API service.
* **params** - (document) data for the service call - must be a BSON document (ruby Hash, python dict, Javascript Object).

Requests are encoded as BSON hashes when transmitted in messages.

```ruby
{ 'name'   => 'some_service',
  'params' => { 'key' => 'value' }
}

request = Sanford::Protocol::Request.parse(a_bson_request_hash)
request.name     #=> "some_service"
request.params   #=> { 'key' => 'value' }
request.to_s     #=> "some_service"
```

## Response

A response is made up of 2 parts: the status and the data.

* **status** - (tuple, required) A code and message describing the result of the service call.
* **data** - (object, optional) Return value of the service call. This can be any BSON serializable object.  Typically won't be set if the request is not successful.

Responses are encoded as BSON hashes when transmitted in messages.

```ruby
{ 'status'  => [ 200, 'The request was successful.' ]
  'data'    => true
}

response = Sanford::Protocol::Response.parse(a_bson_response_hash)
response.status.code    #=> 200
response.status.to_i    #=> 200
response.status.name    #=> "OK"
response.status.message #=> "The request was successful."
response.status.to_s    #=> "[200, OK]"
response.code           #=> 200
response.to_s           #=> "[200, OK]"
response.data           #=> true
```

### Status Codes

This is the list of defined status codes.

* `200` - `ok` - The request was successful.
* `400` - `bad_request` - The request couldn't be read. This is usually because it was not formed correctly.
* `404` - `not_found` - The server couldn't find something requested.
* `408` - `timeout` - A client connected but didn't write a request before the server timeod out waiting for one.
* `500` - `error` - The server errored responding to the request.

In addition to these, a service can return custom status codes, but they should use a number greater than or equal to `600` to avoid collisions with Sanford's defined status codes.

## Usage

The `Sanford::Protocol` module defines helper methods for encoding and decoding messages.

```ruby
# encode a message
data = { 'something' => true }
msg_body = Sanford::Protocol.msg_body.encode(data)
msg_size = Sanford::Protocol.msg_size.encode(msg_body.bytesize)
msg = [Sanford::Protocol.msg_version, msg_size, msg_body].join
```

### Connection

If you are sending and receiving messages using a tcp socket, use `Sanford::Protocol::Connection`.

```ruby
connection = Sanford::Protocol::Connection.new(tcp_socket)
incoming_data = connection.read
connection.write(outgoing_data)
```

For incoming messages, it reads them off the socket, validates them, and returns the decoded body data.  For outgoing messages, it encodes the message body from given data, adds the appropiate message headers, and writes the message to the socket.

#### Timeout

When reading data from a connection, you can optionally pass a timeout value.  If given, the connection will block and wait until data is ready to be read.  If a timeout occurs, the connection will raise `TimeoutError`.

```ruby
begin
  connection.read(10)  # timeout after waiting on data for 10s
rescue Sanford::Protocol::TimeoutError => err
  puts "timeout - so sad :("
end
```

### Requests And Responses

Request and response objects have helpers for sending and receiving data using a connection.

```ruby
# For a server...
# use Request#parse to build an incoming request
data_hash = server_connection.read
incoming_request = Sanford::Protocol::Request.parse(data_hash)
# use Response#to_hash to send a response
outgoing_response = Sanford::Protocol::Response.new(status, data)
server_connection.write(outgoing_response.to_hash)

# For a client...
# use Request#to_hash to send a request
outgoing_request = Sanford::Protocol::Request.new(name, params)
client_connection.write(outgoing_request.to_hash)
# use Response#parse to build an incoming response
data_hash = client_connection.read
incoming_response = Sanford::Protocol::Response.parse(data_hash)
```

## Test Helpers

A `FakeSocket` helper class and an associated `Test::Helpers` module are provided to help test receiving and sending Sanford::Protocol messages without using real sockets.

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
