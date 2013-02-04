# The FakeSocket class can be used to work with Sanford Protocol in a test
# environment. Instead of passing a real socket, pass an instance of this class.
# It mimics the socket API that sanford is concerned with.

require 'sanford-protocol'
require 'sanford-protocol/request'

module Sanford::Protocol::Test
  class FakeSocket

    def self.with_request(*request_params)
      request = Sanford::Protocol::Request.new(*request_params)
      self.with_msg_body(request.to_hash)
    end

    def self.with_msg_body(body, size=nil, encoded_version=nil)
      encoded_body = Sanford::Protocol.msg_body.encode(body)
      self.with_encoded_msg_body(encoded_body, size, encoded_version)
    end

    def self.with_encoded_msg_body(encoded_body, size=nil, encoded_version=nil)
      encoded_size    =   Sanford::Protocol.msg_size.encode(size || encoded_body.bytesize)
      encoded_version ||= Sanford::Protocol.msg_version
      self.new(encoded_version, encoded_size, encoded_body)
    end

    def initialize(*bytes)
      @out = StringIO.new
      @in  = StringIO.new
      reset(*bytes)
    end

    def reset(*new_bytes)
      @in << new_bytes.join; @in.rewind;
    end

    def in;  @in.string;  end
    def out; @out.string; end

    # Socket methods -- requied by Sanford::Protocol

    def recv(number_of_bytes, flags = nil)
      @in.read(number_of_bytes.to_i) || ""
    end

    def send(bytes, flag)
      @out << bytes
    end

    def close
      @closed = true
    end

    def closed?
      !!@closed
    end

    def eof
      @eof = true
    end

    def eof?
      !!@eof
    end

  end
end
