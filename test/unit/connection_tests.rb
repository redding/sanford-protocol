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

    should have_instance_methods :read, :write, :close

    should "read messages off the socket with #read" do
      assert_equal @data, subject.read
    end

    should "write messages to the socket with #write" do
      subject.write(@data)
      assert_equal @msg, @socket.out
    end

    should "close the socket with #close" do
      subject.close
      assert @socket.closed?
    end
  end

  class TimeoutTests < BaseTests
    desc "when timing out on a read"
    setup do
      IO.stubs(:select).returns(nil) # mock IO.select behavior when it times out
    end
    teardown do
      IO.unstub(:select)
    end

    should "raise `TimeoutError` if given a timeout value" do
      assert_raises(Sanford::Protocol::TimeoutError) { subject.read(1) }
    end

  end

end
