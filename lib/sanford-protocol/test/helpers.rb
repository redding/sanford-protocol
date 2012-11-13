require 'sanford-protocol/test/fake_socket'

module Sanford::Protocol::Test

  module Helpers
    extend self

    def fake_socket_with_request(*args)
      FakeSocket.with_request(*args)
    end

    def fake_socket_with_message(*args)
      FakeSocket.with_message(*args)
    end

    def fake_socket_with_encoded_message(*args)
      FakeSocket.with_encoded_message(*args)
    end

    def fake_socket_with(*args)
      FakeSocket.with(*args)
    end

    def read_response_from_fake_socket(fake_socket)
      socket = FakeSocket.new
      socket.add_to_read_stream(fake_socket.written)
      connection = Sanford::Protocol::Connection.new(socket)
      message = connection.read
      Sanford::Protocol::Response.parse(message)
    end

  end

end
