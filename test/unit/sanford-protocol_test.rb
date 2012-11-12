# These tests are intended to be brittle and make sure the protocol conforms to
# an expected spec. If any of these tests fail, you probably need to modify the
# protocol's version constant.
#
require 'assert'

module Sanford::Protocol

  class BaseTest < Assert::Context
    desc "Sanford::Protocol"
    subject{ Sanford::Protocol }

    should have_instance_methods :protocol_version, :number_size_bytes, :number_version_bytes,
      :serialize_size, :deserialize_size, :serialize_message, :deserialize_message

    should "define the protocol's version" do
      expected = [ Sanford::Protocol::VERSION ].pack('C')

      assert_equal 1, Sanford::Protocol::VERSION
      assert_equal expected, Sanford::Protocol.protocol_version
    end

    should "define the number of size bytes" do
      assert_equal 4, Sanford::Protocol.number_size_bytes
    end

    should "define the number of version bytes" do
      assert_equal 1, Sanford::Protocol.number_version_bytes
    end

    should "serialize and deserialize the size part of the protocol" do
      expected_size = (2 ** 32) - 1 # the max number it supports
      expected_serialized = [ expected_size ].pack('N')

      assert_equal expected_serialized, Sanford::Protocol.serialize_size(expected_size)
      assert_equal expected_size, Sanford::Protocol.deserialize_size(expected_serialized)
    end

    should "serialize and deserialize the message part of the protocol" do
      expected_message = {
        'string'  => 'test',
        'int'     => 1,
        'float'   => 2.1,
        'boolean' => true,
        'array'   => [ 1, 2, 3 ],
        'hash'    => { 'something' => 'else' }
      }
      expected_serialized = ::BSON.serialize(expected_message).to_s

      assert_equal expected_serialized, Sanford::Protocol.serialize_message(expected_message)
      assert_equal expected_message, Sanford::Protocol.deserialize_message(expected_serialized)
    end
  end

end
