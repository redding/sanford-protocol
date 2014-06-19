require 'sanford-protocol/response_status'

# The Response class models a specific type of Sanford message body and provides
# a defined structure for it. A response requires a message body to contain a
# status and some data.

module Sanford; end
module Sanford::Protocol

  class Response < Struct.new(:status, :data)

    def self.parse(hash)
      self.new(hash['status'], hash['data'])
    end

    def initialize(status, data=nil)
      super(build_status(status), data)
    end

    def code; status.code; end
    def to_s; status.to_s; end

    def to_hash
      { 'status' => [ status.code, status.message ],
        'data'   => data
      }
    end

    def inspect
      reference = '0x0%x' % (self.object_id << 1)
      "#<#{self.class}:#{reference} @status=#{status} @data=#{data.inspect}>"
    end

    def ==(other)
      if other.kind_of?(self.class)
        self.to_hash == other.to_hash
      else
        super
      end
    end

    private

    def build_status(status)
      return status if status.kind_of?(ResponseStatus)
      ResponseStatus.new(*status)
    end

  end

end
