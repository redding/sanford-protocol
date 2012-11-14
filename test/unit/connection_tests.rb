require 'assert'
require 'sanford-protocol/connection'

class Sanford::Protocol::Connection

  class BaseTests < Assert::Context
    desc "Sanford::Protocol::Connection"
    setup do
      @data = { 'something' => true }
      @encoded_body = Sanford::Protocol.msg_body.encode(@data)
      @encoded_size = Sanford::Protocol.msg_size.encode(@encoded_body.bytesize)
      @msg = [ Sanford::Protocol.msg_version, @encoded_size, @encoded_body ].join
      @socket     = FakeSocket.new
      @connection = Sanford::Protocol::Connection.new(@socket)
    end
    subject{ @connection }

    should have_instance_methods :read, :write

    should "read messages off the socket with #read" do
      @socket.add_to_read_stream(@msg)
      assert_equal @data, subject.read
    end

    should "write messages to the socket with #write" do
      subject.write(@data)
      assert_equal @msg, @socket.written
    end
  end

end
