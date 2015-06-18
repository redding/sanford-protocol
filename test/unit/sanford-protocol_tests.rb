require 'assert'
require 'sanford-protocol'

# These tests are intended to be brittle and make sure the protocol conforms to
# an expected spec. If any of these tests fail, you probably need to modify the
# protocol's version constant.

module Sanford::Protocol

  class UnitTests < Assert::Context
    desc "Sanford::Protocol"
    subject{ Sanford::Protocol }

    should have_imeths :msg_version, :msg_size, :msg_body

    should "define the protocol version" do
      assert_equal 2, subject::VERSION
    end

    should "encode the protocol version to a 1B binary string" do
      assert_equal 1, subject.msg_version.bytesize

      exp = [subject::VERSION].pack('C')
      assert_equal exp, subject.msg_version
    end

    should "encode/decode the size to/from a 4B binary string" do
      assert_equal 4, subject.msg_size.bytes

      size   = (2 ** 32) - 1 # the max number it supports
      binary = [size].pack('N')
      assert_equal binary, subject.msg_size.encode(size)
      assert_equal size,   subject.msg_size.decode(binary)
    end

    should "encode the body to BSON" do
      data = {
        'string'  => Factory.string,
        'int'     => Factory.integer,
        'float'   => Factory.float,
        'boolean' => Factory.boolean,
        'array'   => Factory.integer(3).times.map{ Factory.integer },
        'hash'    => { Factory.string => Factory.string }
      }
      binary = ::BSON.serialize(data).to_s

      assert_equal binary, subject.msg_body.encode(data)
      assert_equal data,   subject.msg_body.decode(binary)
    end

  end

  class StringifyParamsTests < UnitTests
    desc "StringifyParams"
    subject{ StringifyParams }

    should have_imeths :new

    should "convert all hash keys to strings" do
      key, value = Factory.string.to_sym, Factory.string
      result = subject.new({
        key    => value,
        :hash  => { key => [value] },
        :array => [{ key => value }]
      })
      exp = {
        key.to_s => value,
        'hash'   => { key.to_s => [value] },
        'array'  => [{ key.to_s => value }]
      }
      assert_equal exp, result
    end

  end

end
