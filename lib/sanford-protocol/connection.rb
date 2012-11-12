# Sanford Protocol's connection class wraps a socket and provides a `read` and
# `write` method for working with Sanford's communication protocol. When it's
# `read` method is called, it tries to pull off a message from a socket, using
# the helper methods in the `Sanford::Protocol` mixin. The `write` method
# provides the opposite behavior of taking a message and writing it to the
# socket. This class makes it simple for a server or client to communicate using
# Sanford's communication protocol.
#
module Sanford::Protocol

  class Connection
    include Sanford::Protocol

    attr_reader :socket

    def initialize(socket)
      @socket = socket
    end

    def read
      size = self.read_size
      protocol_version = self.read_protocol_version
      message = self.read_message(size)
      self.validate_message!(protocol_version)
      message
    end

    def write(body)
      serialized_message = self.serialize_message(body)
      serialized_size = self.serialize_size(serialized_message.bytesize)
      bytes = [ serialized_size, self.protocol_version, serialized_message ].join
      self.socket.send(bytes, 0)
    end

    protected

    def validate_message!(protocol_version)
      if protocol_version != self.protocol_version
        raise BadMessageError.new("The protocol version didn't match the servers.")
      end
      true
    end

    def read_size
      serialized_size = self.read_from_socket(self.number_size_bytes)
      self.deserialize_size(serialized_size) || raise("nil size read from socket")
    rescue Exception => exception
      raise BadMessageError.new("The size couldn't be read.", exception)
    end

    def read_protocol_version
      self.read_from_socket(self.number_version_bytes)
    rescue Exception => exception
      raise BadMessageError.new("The protocol version couldn't be read.", exception)
    end

    def read_message(size)
      serialized_message = self.read_from_socket(size)
      self.deserialize_message(serialized_message)
    rescue Exception => exception
      raise BadMessageError.new("The message couldn't be read.", exception)
    end

    def read_from_socket(number_of_bytes)
      self.socket.recvfrom(number_of_bytes).first
    end

  end

  # The BadMessageError class has the tendency to "hide" errors. In non-testing,
  # this is ideal and allows Sanford servers to catch a common exception and
  # respond in a standard way. In a testing environment though, it's better to
  # go ahead and see the real exception. Thus, we set the environment variable
  # SANFORD_PROTOCOL_DEBUG.
  #
  class BadMessageError < RuntimeError

    def initialize(message, exception = nil)
      if exception && ENV['SANFORD_PROTOCOL_DEBUG']
        raise(exception)
      else
        super(message)
      end
    end
  end

end
