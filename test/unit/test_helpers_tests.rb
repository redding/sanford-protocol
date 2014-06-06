require 'assert'
require 'sanford-protocol/test_helpers'

require 'sanford-protocol/response'

module Sanford::Protocol::TestHelpers

  class UnitTests < Assert::Context
    desc "Sanford::Protocol::TestHelpers"
    subject { Sanford::Protocol::TestHelpers }

    should have_imeths :fake_socket_with_request, :fake_socket_with_msg_body
    should have_imeths :fake_socket_with_encoded_msg_body, :fake_socket_with
    should have_imeths :read_response_from_fake_socket
    should have_imeths :read_written_response_from_fake_socket

    should "be able to read responses given a fake socket" do
      setup_some_response_data
      fs = FakeSocket.new(@msg)
      response = subject.read_response_from_fake_socket(fs)

      assert_kind_of Sanford::Protocol::Response, response
      assert_equal @data, response.to_hash
    end

    should "be able to read responses written to a fake socket" do
      setup_some_response_data
      fs = FakeSocket.new; fs.send(@msg, 0)
      response = subject.read_written_response_from_fake_socket(fs)

      assert_kind_of Sanford::Protocol::Response, response
      assert_equal @data, response.to_hash
    end

  end

end
