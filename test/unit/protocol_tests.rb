# These tests are intended to be brittle and make sure the protocol conforms to
# an expected spec. If any of these tests fail, you probably need to modify the
# protocol's version constant.

require 'assert'
require 'sanford-protocol'

module Sanford::Protocol
  class BaseTests < Assert::Context
    desc "Sanford::Protocol"
    subject{ Sanford::Protocol }

    should have_instance_methods :msg_version, :msg_size, :msg_body

    should "define the protocol version" do
      assert_equal 2, subject::VERSION
    end

    should "encode the protocol version to a 1B binary string" do
      assert_equal 1, subject.msg_version.bytesize

      expected = [ subject::VERSION ].pack('C')
      assert_equal expected, subject.msg_version
    end

    should "encode/decode the size to/from a 4B binary string" do
      assert_equal 4, subject.msg_size.bytes

      size   = (2 ** 32) - 1 # the max number it supports
      binary = [ size ].pack('N')
      assert_equal binary, subject.msg_size.encode(size)
      assert_equal size,   subject.msg_size.decode(binary)
    end

    should "encode the body to BSON" do
      data = {
        'string'  => 'test',
        'int'     => 1,
        'float'   => 2.1,
        'boolean' => true,
        'array'   => [ 1, 2, 3 ],
        'hash'    => { 'something' => 'else' }
      }
      binary = ::BSON.serialize(data).to_s

      assert_equal binary, subject.msg_body.encode(data)
      assert_equal data,   subject.msg_body.decode(binary)
    end

  end
end
