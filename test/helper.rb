ENV['SANFORD_PROTOCOL_DEBUG'] = 'yes'

ROOT = File.expand_path('../..', __FILE__)

require 'sanford-protocol'

require 'sanford-protocol/test/fake_socket'
FakeSocket = Sanford::Protocol::Test::FakeSocket

if defined?(Assert)
  require 'assert-mocha'
end
