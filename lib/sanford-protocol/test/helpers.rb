require 'sanford-protocol/test/fake_socket'
require 'sanford-protocol/response'

module Sanford::Protocol::Test

  module Helpers
    extend self

    def fake_socket_with_request(*args)
      FakeSocket.with_request(*args)
    end

    def fake_socket_with_msg_body(*args)
      FakeSocket.with_msg_body(*args)
    end

    def fake_socket_with_encoded_msg_body(*args)
      FakeSocket.with_encoded_msg_body(*args)
    end

    def fake_socket_with(*args)
      FakeSocket.new(*args)
    end

    def read_response_from_fake_socket(from_fake_socket)
      data = Sanford::Protocol::Connection.new(from_fake_socket).read
      Sanford::Protocol::Response.parse(data)
    end

    def read_written_response_from_fake_socket(from_fake_socket)
      read_response_from_fake_socket(FakeSocket.new(from_fake_socket.out))
    end

  end

end
