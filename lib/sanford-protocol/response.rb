require 'sanford-protocol/response_status'

# The Response class models a specific type of Sanford message body and provides
# a defined structure for it. A response requires a message body to contain a
# status (which is a code and optional message) and a result. It provides
# methods for working with message bodies (hashes) with `parse` and `to_hash`.

module Sanford::Protocol

  class Response

    def self.parse(hash)
      self.new(hash['status'], hash['result'])
    end

    attr_reader :status, :result

    def initialize(status, result = nil)
      @status, @result = build_status(status), result
    end

    def to_hash
      { 'status'  => [ @status.code, @status.message ],
        'result'  => @result
      }
    end

    def inspect
      reference = '0x0%x' % (self.object_id << 1)
      "#<#{self.class}:#{reference}"\
      " @status=#{@status.inspect}"\
      " @result=#{@result.inspect}>"
    end

    private

    def build_status(status)
      return status if status.kind_of?(ResponseStatus)

      ResponseStatus.new(*status)
    end

  end

end
