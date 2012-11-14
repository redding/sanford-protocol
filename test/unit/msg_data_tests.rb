require 'assert'
require 'sanford-protocol/msg_data'
require 'sanford-protocol'

class Sanford::Protocol::MsgData

  class BadMessageTests < Assert::Context
    desc "reading data on a bad message"
    setup do
      @debug = ENV['SANFORD_PROTOCOL_DEBUG']
      ENV.delete('SANFORD_PROTOCOL_DEBUG')

      @connection = Sanford::Protocol::Connection.new(FakeSocket.new)
      @socket     = @connection.instance_variable_get "@socket"
    end
    teardown do
      ENV['SANFORD_PROTOCOL_DEBUG'] = @debug
    end
    subject{ @connection }

    def assert_bad_message(expected_msg)
      exception = begin; subject.read; rescue Exception => err; err; end
      assert_instance_of Sanford::Protocol::BadMessageError, exception
      assert_equal expected_msg, exception.message
    end

  end

  class BadSizeTests < BadMessageTests
    desc "that errors when reading the size part"
    setup do
      @socket.stubs(:read).  # when reading the size, fail
        with(Sanford::Protocol.msg_size.bytes).
        raises("simulated socket read error!")
    end
    teardown do
      @socket.unstub(:read)
    end

    should "raise a BadMessageError with a relevant message" do
      assert_bad_message "Error reading message body size."
    end
  end

  class BadVersionTests < BadMessageTests
    desc "that errors when reading the version part"
    setup do
      @socket.stubs(:read).  # when reading the size, succeed
        with(Sanford::Protocol.msg_size.bytes).
        returns(Sanford::Protocol.msg_size.encode(50))
      @socket.stubs(:read).  # when reading the version, fail
        with(Sanford::Protocol.msg_version.bytesize).
        raises("simulated socket read error!")
    end
    teardown do
      @socket.unstub(:read)
    end

    should "raise a BadMessageError with a relevant message" do
      assert_bad_message "Error reading message protocol version"
    end
  end

  class BadBodyTests < BadMessageTests
    desc "that errors when reading the body part"
    setup do
      @socket.stubs(:read).  # when reading the size, succeed
        with(Sanford::Protocol.msg_size.bytes).
        returns(Sanford::Protocol.msg_size.encode(50))
      @socket.stubs(:read).  # when reading the version, succeed
        with(Sanford::Protocol.msg_version.bytesize).
        returns(Sanford::Protocol.msg_version)
      @socket.stubs(:read).  # when reading the body, fail
        with(50).
        raises("simulated socket read error!")
    end
    teardown do
      Sanford::Protocol.unstub(:read)
    end

    should "raise a BadMessageError with a relevant message" do
      assert_bad_message "Error reading message body."
    end
  end

  class NilSizeTests < BadMessageTests
    desc 'that reads a nil size'
    setup do
      @socket.stubs(:read).  # when reading the size, fail
        with(Sanford::Protocol.msg_size.bytes).
        returns(nil)
    end
    teardown do
      @socket.unstub(:read)
    end

    should "raise a BadMessageError with a relevant message" do
      assert_bad_message "Empty message size"
    end
  end

  class VersionMismatchTests < BadMessageTests
    desc "with a mismatched protocol version"
    setup do
      @socket.stubs(:read).  # when reading the size, succeed
        with(Sanford::Protocol.msg_size.bytes).
        returns(Sanford::Protocol.msg_size.encode(50))
      @socket.stubs(:read).  # when reading the version, fail
        with(Sanford::Protocol.msg_version.bytesize).
        returns(Sanford::Protocol::PackedHeader.new(1, 'C').encode(0))
    end
    teardown do
      @socket.unstub(:read)
    end

    should "raise a BadMessageError with a relevant message" do
      assert_bad_message "Protocol version mismatch"
    end
  end

end
