require 'assert'
require 'sanford-protocol/test/fake_socket'
require 'sanford-protocol/request'

class Sanford::Protocol::Test::FakeSocket

  class BaseTests < Assert::Context
    desc "a FakeSocket"
    setup do
      @fs = FakeSocket.new
    end
    subject { @fs }

    should have_cmeths :with_request, :with_msg_body, :with_encoded_msg_body
    should have_imeths :in, :out, :reset
    should have_imeths :recvfrom, :send

    should "have no `in` or `out` data by default" do
      assert_empty subject.in
      assert_empty subject.out
    end

    should "push `out` data using #send" do
      subject.send('some out data', 0)
      assert_equal 'some out data', subject.out
    end

  end

  class WithInDataTests < BaseTests
    desc "created given some data"
    setup do
      @in_data = 'some in data'
      @fs = FakeSocket.new(@in_data)
    end

    should "add the data as `in` data" do
      assert_equal @in_data, subject.in
    end

    should "pull `in` data using #recvfrom" do
      recvfrom_data = subject.recvfrom(@in_data.bytesize)

      assert_kind_of ::Array, recvfrom_data
      assert_equal @in_data, recvfrom_data.first
    end

    should "reset its `in` data using #reset" do
      subject.reset('some different in data')
      assert_equal 'some different in data', subject.in
    end

  end

  class EncodedMessageTests < BaseTests
    desc "with encoded msg data"
    setup do
      setup_some_msg_data
    end

    should "build with the msg as `in` data given the encoded msg body" do
      s = FakeSocket.with_encoded_msg_body(@encoded_body)
      assert_equal @msg, s.in
    end

    should "build with the msg as `in` data given the unencoded msg body" do
      s = FakeSocket.with_msg_body(@data)
      assert_equal @msg, s.in
    end

  end

  class RequestTests < BaseTests
    desc "that is a request"
    setup do
      setup_some_request_data
    end

    should "build with the request msg as `in` data given the request" do
      s = FakeSocket.with_request(*@request_params)
      assert_equal @msg, s.in
    end
  end

end
