require 'sanford-protocol/fake_socket'
require 'sanford-protocol/connection'
require 'sanford-protocol/response'

module Sandord; end
module Sanford::Protocol

  module TestHelpers
    extend self

    def fake_socket_with_request(*args)
      Sanford::Protocol::FakeSocket.with_request(*args)
    end

    def fake_socket_with_msg_body(*args)
      Sanford::Protocol::FakeSocket.with_msg_body(*args)
    end

    def fake_socket_with_encoded_msg_body(*args)
      Sanford::Protocol::FakeSocket.with_encoded_msg_body(*args)
    end

    def fake_socket_with(*args)
      Sanford::Protocol::FakeSocket.new(*args)
    end

    def read_response_from_fake_socket(from_fake_socket)
      data = Sanford::Protocol::Connection.new(from_fake_socket).read
      Sanford::Protocol::Response.parse(data)
    end

    def read_written_response_from_fake_socket(from_fake_socket)
      read_response_from_fake_socket(Sanford::Protocol::FakeSocket.new(from_fake_socket.out))
    end

  end

end
