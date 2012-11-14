require 'assert'
require 'sanford-protocol/connection'

class Sanford::Protocol::Connection

  class BaseTests < Assert::Context
    desc "Sanford::Protocol::Connection"
    setup do
      setup_some_msg_data
      @socket     = FakeSocket.new(@msg)
      @connection = Sanford::Protocol::Connection.new(@socket)
    end
    subject{ @connection }

    should have_instance_methods :read, :write

    should "read messages off the socket with #read" do
      assert_equal @data, subject.read
    end

    should "write messages to the socket with #write" do
      subject.write(@data)
      assert_equal @msg, @socket.out
    end
  end

end
