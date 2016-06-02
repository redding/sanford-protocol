require 'assert'
require 'sanford-protocol/connection'

class Sanford::Protocol::Connection

  class UnitTests < Assert::Context
    desc "Sanford::Protocol::Connection"
    setup do
      setup_some_msg_data
      @socket     = FakeSocket.new(@msg)
      @connection = Sanford::Protocol::Connection.new(@socket)
    end
    subject{ @connection }

    should have_instance_methods :read, :write, :close, :peek, :close_write

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

    should "look at the first byte of data on the socket with #peek" do
      assert_equal @socket.in[0, 1], subject.peek
    end

    should "close the write stream of the socket with #close_write" do
      subject.close_write
      assert @socket.write_stream_closed?
    end

  end

  class RealConnectionTests < UnitTests

    def start_server(options, &block)
      begin
        # this `fork` is a separate process, so it runs parallel to the code
        # after its block
        pid = fork do
          tcp_server = TCPServer.open 'localhost', 12000
          trap("TERM"){ tcp_server.close }
          socket = tcp_server.accept # blocks here, waits for `block` to connect
          options[:serve].call(socket) if options[:serve]
        end
        sleep 0.2 # give the server time to boot
        yield
      ensure
        if pid
          Process.kill("TERM", pid)
          Process.wait(pid)
        end
      end
    end

  end

  class TimeoutTests < RealConnectionTests
    desc "when timing out on a read"

    should "raise `TimeoutError` if given a timeout value" do
      self.start_server(:serve => proc{ sleep 0.2 }) do
        connection = Sanford::Protocol::Connection.new(TCPSocket.new('localhost', 12000))
        assert_raises(Sanford::Protocol::TimeoutError) { connection.read(0.1) }
      end
    end

  end

end
