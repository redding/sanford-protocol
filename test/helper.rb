ROOT = File.expand_path('../..', __FILE__)

ENV['SANFORD_PROTOCOL_DEBUG'] = 'yes'

require 'sanford-protocol/test/fake_socket'
FakeSocket = Sanford::Protocol::Test::FakeSocket

require 'assert-mocha' if defined?(Assert)

class Assert::Context

  def setup_some_msg_data(data=nil)
    @data = data || { 'something' => true }
    @encoded_body    = Sanford::Protocol.msg_body.encode(@data)
    @encoded_size    = Sanford::Protocol.msg_size.encode(@encoded_body.bytesize)
    @encoded_version = Sanford::Protocol.msg_version
    @msg = [@encoded_version, @encoded_size, @encoded_body].join
  end

  def setup_some_request_data
    @request_params = ['1', 'a_service', {:some => 'data'}]
    @request = Sanford::Protocol::Request.new(*@request_params)
    setup_some_msg_data(@request.to_hash)
  end

  def setup_some_response_data
    @response_params = [200, 'in testing all is well']
    @response = Sanford::Protocol::Response.new(*@response_params)
    setup_some_msg_data(@response.to_hash)
  end

end
