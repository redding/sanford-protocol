require 'assert'
require 'sanford-protocol/fake_connection'

class Sanford::Protocol::FakeConnection

  class UnitTests < Assert::Context
    desc "Sanford::Protocol::FakeConnection"
    setup do
      @read_data = Factory.binary
      @fake_connection = Sanford::Protocol::FakeConnection.new(@read_data)
    end
    subject{ @fake_connection }

    should have_accessors :read_data, :peek_data, :write_data
    should have_accessors :closed, :closed_write
    should have_readers :read_timeout, :peek_timeout
    should have_imeths :read, :write, :peek, :close, :close_write

    should "know its read data and peek data" do
      assert_equal @read_data, subject.read_data
      assert_equal @read_data[1], subject.peek_data
    end

    should "default its attributes" do
      fake_connection = Sanford::Protocol::FakeConnection.new
      assert_equal "", fake_connection.read_data
      assert_equal "", fake_connection.peek_data
      assert_nil fake_connection.write_data
      assert_false fake_connection.closed
      assert_false fake_connection.closed_write
      assert_nil fake_connection.read_timeout
      assert_nil fake_connection.peek_timeout
    end

    should "allow reading the read data using `read`" do
      assert_nil subject.read_timeout
      result = subject.read
      assert_equal subject.read_data, result
      assert_nil subject.read_timeout

      timeout = Factory.integer
      assert_nil subject.read_timeout
      result = subject.read(timeout)
      assert_equal timeout, subject.read_timeout
    end

    should "allow writing to the write data using `write`" do
      data = Factory.boolean
      assert_nil subject.write_data
      subject.write(data)
      assert_equal data, subject.write_data
    end

    should "allow reading the peek data using `peek`" do
      assert_nil subject.peek_timeout
      result = subject.peek
      assert_equal subject.peek_data, result
      assert_nil subject.peek_timeout

      timeout = Factory.integer
      assert_nil subject.peek_timeout
      result = subject.peek(timeout)
      assert_equal timeout, subject.peek_timeout
    end

    should "close itself using `close`" do
      assert_false subject.closed
      subject.close
      assert_true subject.closed
    end

    should "close its write using `close_write`" do
      assert_false subject.closed_write
      subject.close_write
      assert_true subject.closed_write
    end

  end

end
