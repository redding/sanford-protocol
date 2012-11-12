# The Response class models a specific type of Sanford message body and provides
# a defined structure for it. A response requires a message body to contain a
# status (which is a code and optional message) and a result. It provides
# methods for working with message bodies (hashes) with `parse` and `to_hash`.
#
require 'sanford-protocol/response_status'

module Sanford::Protocol

  class Response

    def self.parse(hash)
      self.new(hash['status'], hash['result'])
    end

    attr_reader :status, :result

    def initialize(status, result = nil)
      @status, @result = self.build_status(status), result
    end

    def to_hash
      { 'status'  => [ self.status.code, self.status.message ],
        'result'  => self.result
      }
    end

    def inspect
      reference = '0x0%x' % (self.object_id << 1)
      "#<#{self.class}:#{reference} @status=#{self.status.inspect} @result=#{self.result.inspect}>"
    end

    protected

    def build_status(status)
      if status.kind_of?(Array)
        Sanford::Protocol::ResponseStatus.new(*status)
      elsif status.kind_of?(Sanford::Protocol::ResponseStatus)
        status
      else
        Sanford::Protocol::ResponseStatus.new(status)
      end
    end

  end

end
