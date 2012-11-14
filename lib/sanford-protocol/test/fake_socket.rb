# The FakeSocket class can be used to work with Sanford Protocol in a test
# environment. Instead of passing a real socket, pass an instance of this class.
# It provides methods for adding to it's "read stream" and viewing what has been
# written to it's "write stream". For example:
#
#     socket = FakeSocket.new
#     socket.add_to_read_stream(bytes)
#     connection = Sanford::Protocol::Connection.new(socket)
#     message = connection.read
#     # do something, generate new_message
#     connection.write(new_message)
#     puts socket.written # => serialized new_message
#
module Sanford::Protocol::Test

  class FakeSocket

    def initialize
      @read_stream = StringIO.new
      @write_stream = StringIO.new
    end

    def add_to_read_stream(bytes)
      @read_stream << bytes
      @read_stream.rewind
    end

    def written
      @write_stream.string
    end

    # Socket methods -- requied by Sanford::Protocol

    def recvfrom(number_of_bytes)
      [ @read_stream.read(number_of_bytes.to_i) ]
    end

    def send(bytes, flag)
      @write_stream << bytes
    end

  end

end
