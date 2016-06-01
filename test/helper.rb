# this file is automatically required when you run `assert`
# put any test helpers here

# add the root dir to the load path
$LOAD_PATH.unshift(File.expand_path("../..", __FILE__))

# require pry for debugging (`binding.pry`)
require 'pry'

ENV['SANFORD_PROTOCOL_DEBUG'] = 'yes'

require 'sanford-protocol/fake_socket'
FakeSocket = Sanford::Protocol::FakeSocket

require 'test/support/factory'

# 1.8.7 backfills

# Array#sample
if !(a = Array.new).respond_to?(:sample) && a.respond_to?(:choice)
  class Array
    alias_method :sample, :choice
  end
end

class Assert::Context

  def setup_some_msg_data(data = nil)
    @data = data || { 'something' => true }
    @encoded_body    = Sanford::Protocol.msg_body.encode(@data)
    @encoded_size    = Sanford::Protocol.msg_size.encode(@encoded_body.bytesize)
    @encoded_version = Sanford::Protocol.msg_version
    @msg = [@encoded_version, @encoded_size, @encoded_body].join
  end

  def setup_some_request_data
    @request_params = ['a_service', {:some => 'data'}]
    @request = Sanford::Protocol::Request.new(*@request_params)
    setup_some_msg_data(@request.to_hash)
  end

  def setup_some_response_data
    @response_params = [200, 'in testing all is well']
    @response = Sanford::Protocol::Response.new(*@response_params)
    setup_some_msg_data(@response.to_hash)
  end

end
