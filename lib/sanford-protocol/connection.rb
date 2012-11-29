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
    # |------ 1B -------|------ 4B -------|-- (msg body size)B --|
    # | (packed header) | (packed header) | (BSON binary string) |
    # |   msg version   |  msg body size  |       msg body       |
    # |-----------------|-----------------|----------------------|

    def read(timeout=nil)
      wait_for_data(timeout) if timeout
      MsgVersion.new{ @socket.read msg_version.bytesize }.validate!
      size = MsgSize.new{ @socket.decode msg_size, msg_size.bytes }.validate!.value
      return MsgBody.new{ @socket.decode msg_body, size           }.validate!.value
    end

    def write(data)
      body = @socket.encode msg_body, data
      size = @socket.encode msg_size, body.bytesize

      @socket.write(msg_version, size, body)
    end

    def close
      @socket.close
    end

    private

    def wait_for_data(timeout)
      if IO.select([ @socket.tcp_socket ], nil, nil, timeout).nil?
        raise TimeoutError.new(timeout)
      end
    end

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

    def close
      tcp_socket.close rescue false
    end
  end

  class TimeoutError < RuntimeError
    def initialize(timeout)
      super "Timed out waiting for data to read (#{timeout}s)."
    end
  end

end
