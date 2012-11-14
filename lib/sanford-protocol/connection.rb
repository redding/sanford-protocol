require 'sanford-protocol/msg_data'

module Sanford::Protocol

  # Sanford Protocol's connection class wraps a socket and provides a `read` and
  # `write` method for using Sanford's message protocol.  Mixes in the protocol
  # to get the `msg_version`, `msg_size`, and `msg_body` handler methods.

  class Connection
    include Sanford::Protocol

    def initialize(tcp_socket)
      @socket = Socket.new(tcp_socket)
    end

    # Message format (see sanford-protocal.rb):
    # |------ 4B -------|------ 1B -------|-- <msg body size>B --|
    # | (packed header) | (packed header) | (BSON binary string) |
    # |  msg body size  |   msg version   |       msg body       |

    # TODO: change protocol and put version as first thing read/written

    def read
      size = MsgSize.new{ @socket.decode msg_size, msg_size.bytes }.validate!.value
      MsgVersion.new{ @socket.read msg_version.bytesize }.validate!
      return MsgBody.new{ @socket.decode msg_body, size           }.validate!.value
    end

    def write(data)
      body = @socket.encode msg_body, data
      size = @socket.encode msg_size, body.bytesize

      @socket.write(size, msg_version, body)
    end

    class Socket < Struct.new(:tcp_socket)
      def decode(handler, num_bytes)
        handler.decode(read(num_bytes))
      end

      def encode(handler, data)
        handler.encode data
      end

      def read(number_of_bytes)
        tcp_socket.recvfrom(number_of_bytes).first
      end

      def write(*binary_strings)
        tcp_socket.send(binary_strings.join, 0)
      end
    end

  end
end
