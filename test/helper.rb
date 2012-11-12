ENV['SANFORD_PROTOCOL_DEBUG'] = 'yes'

ROOT = File.expand_path('../..', __FILE__)

require 'sanford-protocol'

if defined?(Assert)
  require 'assert-mocha'
end
