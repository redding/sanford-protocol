require 'assert'

class Sanford::Protocol::Connection

  class BaseTest < Assert::Context
    desc "Sanford::Protocol::Connection"
    setup do
      @message = { 'something' => true }
      @serialized_message = Sanford::Protocol.serialize_message(@message)
      @serialized_size = Sanford::Protocol.serialize_size(@serialized_message.bytesize)
      @bytes = [ @serialized_size, Sanford::Protocol.protocol_version, @serialized_message ].join

      @socket = FakeSocket.new
      @connection = Sanford::Protocol::Connection.new(@socket)
    end
    subject{ @connection }

    should have_instance_methods :read, :write, :socket

    should "read messages off the socket with #read" do
      @socket.add_to_read_stream(@bytes)

      assert_equal @message, subject.read
    end

    should "write messages to the socket with #write" do
      subject.write(@message)

      assert_equal @bytes, @socket.written
    end
  end

  class ReadingMessageErrorsTest < Assert::Context
    desc "Sanford::Protocol::Connection errors reading a message"
    setup do
      @debug = ENV['SANFORD_PROTOCOL_DEBUG']
      ENV.delete('SANFORD_PROTOCOL_DEBUG')
      @socket = FakeSocket.new
      @connection = Sanford::Protocol::Connection.new(@socket)
    end
    teardown do
      ENV['SANFORD_PROTOCOL_DEBUG'] = @debug
    end
    subject{ @connection }

  end

  class BadSizeTest < ReadingMessageErrorsTest
    desc "with an invalid size part"
    setup do
      @socket.add_to_read_stream("H")
    end

    should "raise a BadMessageError with a relevant message" do
      exception = nil
      begin; subject.read; rescue Exception => exception; end

      assert_instance_of Sanford::Protocol::BadMessageError, exception
      assert_equal "The size couldn't be read.", exception.message
    end
  end

  class BadProtocolVersionTest < ReadingMessageErrorsTest
    setup do
      serialized_size = Sanford::Protocol.serialize_size(5)
      # when socket reads the size, it should work
      @socket.stubs(:recvfrom).with(Sanford::Protocol.number_size_bytes).returns(serialized_size)
      # when socket reads the protocol version, it should fail
      @socket.stubs(:recvfrom).with(Sanford::Protocol.number_version_bytes).raises("break!")
    end
    teardown do
      @socket.unstub(:recvfrom)
    end

    should "raise a BadMessageError with a relevant message" do
      exception = nil
      begin; subject.read; rescue Exception => exception; end

      assert_instance_of Sanford::Protocol::BadMessageError, exception
      assert_equal "The protocol version couldn't be read.", exception.message
    end
  end

  class BadMessageTest < ReadingMessageErrorsTest
    desc "with an invalid message"
    setup do
      serialized_size = Sanford::Protocol.serialize_size(5)
      bytes = [ serialized_size, Sanford::Protocol.protocol_version ].join
      @socket.add_to_read_stream(bytes)
      Sanford::Protocol.stubs(:deserialize_message).raises("break!")
    end
    teardown do
      Sanford::Protocol.unstub(:deserialize_message)
    end

    should "raise a BadMessageError with a relevant message" do
      exception = nil
      begin; subject.read; rescue Exception => exception; end

      assert_instance_of Sanford::Protocol::BadMessageError, exception
      assert_equal "The message couldn't be read.", exception.message
    end
  end

  class WrongProtocolVersionTest < ReadingMessageErrorsTest
    desc "with the wrong protocol version"
    setup do
      serialized_size = Sanford::Protocol.serialize_size(5)
      bytes = [ serialized_size, "\000", Sanford::Protocol.serialize_message({}) ].join
      @socket.add_to_read_stream(bytes)
    end

    should "raise a BadMessageError with a relevant message" do
      exception = nil
      begin; subject.read; rescue Exception => exception; end

      assert_instance_of Sanford::Protocol::BadMessageError, exception
      assert_equal "The protocol version didn't match the servers.", exception.message
    end
  end

end
