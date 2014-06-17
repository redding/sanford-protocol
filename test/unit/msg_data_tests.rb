require 'assert'
require 'sanford-protocol/msg_data'

require 'sanford-protocol/connection'

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
    desc "that errors when reading the version part"
    setup do
      Assert.stub(@socket, :read).with(Sanford::Protocol.msg_version.bytesize) do
        raises "simulated socket read error!"
      end
    end

    should "raise a BadMessageError with a relevant message" do
      assert_bad_message "Error reading message protocol version"
    end

  end

  class BadVersionTests < BadMessageTests
    desc "that errors when reading the size part"
    setup do
      # when reading the version, succeed
      Assert.stub(@socket, :read).with(Sanford::Protocol.msg_version.bytesize) do
        Sanford::Protocol.msg_version
      end
      # when reading the size, fail
      Assert.stub(@socket, :read).with(Sanford::Protocol.msg_size.bytes) do
        raise "simulated socket read error!"
      end
    end

    should "raise a BadMessageError with a relevant message" do
      assert_bad_message "Error reading message body size."
    end

  end

  class BadBodyTests < BadMessageTests
    desc "that errors when reading the body part"
    setup do
      # when reading the version, succeed
      Assert.stub(@socket, :read).with(Sanford::Protocol.msg_version.bytesize) do
        Sanford::Protocol.msg_version
      end
      # when reading the size, succeed
      Assert.stub(@socket, :read).with(Sanford::Protocol.msg_size.bytes) do
        Sanford::Protocol.msg_size.encode(50)
      end
      # when reading the body, fail
      Assert.stub(@socket, :read).with(50){ raise "simulated socket read error!" }
    end

    should "raise a BadMessageError with a relevant message" do
      assert_bad_message "Error reading message body."
    end

  end

  class NilSizeTests < BadMessageTests
    desc 'that reads a nil size'
    setup do
      # when reading the version, succeed
      Assert.stub(@socket, :read).with(Sanford::Protocol.msg_version.bytesize) do
        Sanford::Protocol.msg_version
      end
      # when reading the size, return nil
      Assert.stub(@socket, :read).with(Sanford::Protocol.msg_size.bytes){ nil }
    end

    should "raise a BadMessageError with a relevant message" do
      assert_bad_message "Empty message size"
    end

  end

  class VersionMismatchTests < BadMessageTests
    desc "with a mismatched protocol version"
    setup do
      # when reading the version, encode wrong number
      Assert.stub(@socket, :read).with(Sanford::Protocol.msg_version.bytesize) do
        Sanford::Protocol::PackedHeader.new(1, 'C').encode(0)
      end
    end

    should "raise a BadMessageError with a relevant message" do
      assert_bad_message "Protocol version mismatch"
    end

  end

end
