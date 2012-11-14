ROOT = File.expand_path('../..', __FILE__)

ENV['SANFORD_PROTOCOL_DEBUG'] = 'yes'

require 'sanford-protocol/test/fake_socket'
FakeSocket = Sanford::Protocol::Test::FakeSocket

require 'assert-mocha' if defined?(Assert)
