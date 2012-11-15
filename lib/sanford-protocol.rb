module Sanford; end

require 'sanford-protocol/connection'
require 'sanford-protocol/request'
require 'sanford-protocol/response'

module Sanford
  module Protocol

    extend self

    # If anything changes in this file, the VERSION number should be
    # incremented. This is used by clients and servers to ensure they are
    # working under the same assumptions. In addition to incrementing this, the
    # README needs to be updated to display the current version and needs to
    # describe everything in this file.

    VERSION = 1

    # The message version is the 1B encoding of the `VERSION` above. It is
    # encoded using Array#pack 'C' (8-bit unsigned integer).   The max value it
    # can encode is 255 (`(2 ** 8) - 1`).

    def msg_version; @msg_version ||= PackedHeader.new(1, 'C').encode(VERSION); end

    # The message size is encoded using Array#pack 'N'. This encoding represents
    # a 32-bit (4 byte) unsigned integer. The max value that can be encoded in
    # 4 bytes is 4,294,967,295 (`(2 ** 32) - 1`) or a size of ~4GB.

    def msg_size; @msg_size ||= PackedHeader.new(4, 'N'); end

    # THe message body is encoded using BSON.

    def msg_body; @msg_body ||= BsonBody.new; end

    class PackedHeader < Struct.new(:bytes, :directive)
      def encode(data);   [*data].pack(directive);             end
      def decode(binary); binary.to_s.unpack(directive).first; end
    end

    class BsonBody
      require 'bson'

      # BSON returns a byte buffer when serializing.  This doesn't always behave
      # like a string, so convert it to one.
      def encode(data); ::BSON.serialize(data).to_s; end

      # BSON returns an ordered hash when deserializing. This should be
      # functionally equivalent to a regular hash.
      def decode(binary); ::BSON.deserialize(binary); end
    end

  end
end
