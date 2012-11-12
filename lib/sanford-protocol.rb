# Sanford Protocol is a module that describes the current protocol and provides
# methods for working with it. This file can be mixed in to other classes to
# allow them to conveniently work with a Sanford server/client.
#
require 'bson'

require 'sanford-protocol/version'

module Sanford
  module Protocol
    extend self

    # If anything changes in this file, the VERSION number should be
    # incremented. This is used by clients and servers to ensure they are
    # working under the same assumptions. In addition to incrementing this, the
    # README needs to be updated to display the current version and needs to
    # describe everything in this file.
    VERSION = 1

    # Protocol Version
    # * Uses Array#pack with 'C', which is an 8-bit (1 byte) unsigned integer.
    #   This converts the version integer to binary:
    #
    #    protocol_version = 1
    #    # printed in binary
    #    sprintf("%08b", protocol_version) # => 00000001
    #    # ruby displays this in octal, with a leading slash
    #    [ printed_version ].pack('C') # => "\001"
    #
    # * Array#pack with 'C' means that our size is always 1 byte. Thus, the
    #   `number_version_bytes` is set to 1. It is implicit that Array#pack with
    #   'C' means 1 byte and that it matches `number_version_bytes`.
    # * The max version integer that can be stored in a single byte is:
    #     (2 ** 8) - 1 OR 255
    #

    def number_version_bytes
      1
    end

    def protocol_version
      @protocol_version ||= [ VERSION ].pack('C')
    end

    # Size
    # * Uses Array#pack with 'N', which is a 32-bit (4 byte) unsigned integer
    #   network byte order. This literally converts an integer to binary:
    #
    #     size = 1643353803 # some nice large number
    #     # printed in binary, broken into 4 bytes (8 bits each)
    #     sprintf("%032b", size) # => 01100001 11110011 10010110 11001011
    #
    # * Array#pack with 'N' means that our size is always 4 bytes. Thus, the
    #   `number_size_bytes` is set to 4, but this does not enforce anything with
    #   the serialize/deserialize methods. It is implicit that 'N' with
    #   Array#pack means 4 bytes and that this matches `number_size_bytes`.
    # * The max size that can be stored in 4 bytes is:
    #     (2 ** 32) - 1 bytes OR 4,294,967,295 bytes OR ~4gb
    #

    def number_size_bytes
      4
    end

    def serialize_size(size)
      [ size.to_i ].pack('N')
    end

    def deserialize_size(serialized_size)
      serialized_size.to_s.unpack('N').first
    end

    # Message
    # * Uses BSON to serialize and deserialize messages.
    # * BSON returns a byte buffer when serializing. This doesn't always behave
    #   like a string, so we convert it to one.
    # * BSON returns an ordered hash when deserializing. This should be
    #   functionally equivalent to a regular hash.
    #

    def serialize_message(message)
      ::BSON.serialize(message).to_s
    end

    def deserialize_message(serialized_message)
      ::BSON.deserialize(serialized_message)
    end

  end
end
