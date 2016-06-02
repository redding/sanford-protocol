# The Response Status class models a code and optional message. This makes up
# part of a response and provides methods for building and displaying statuses.

module Sanford; end
module Sanford::Protocol

  class ResponseStatus < Struct.new(:code_obj, :message)

    def initialize(code, message = nil)
      super(Code.new(code), message)
    end

    def code; self.code_obj.number; end
    alias_method :to_i, :code

    def code=(new_code)
      self.code_obj = Code.new(new_code)
    end

    def name; code_obj.name; end
    def to_s; code_obj.to_s; end

    def inspect
      reference = '0x0%x' % (self.object_id << 1)
      "#<#{self.class}:#{reference} @code=#{code_obj} @message=#{message.inspect}>"
    end

    class Code < Struct.new(:number, :name)
      NAMES = {
        200 => 'OK',
        400 => 'BAD REQUEST',
        404 => 'NOT FOUND',
        408 => 'TIMEOUT',
        422 => 'INVALID',
        500 => 'ERROR'
      }.freeze

      def initialize(number)
        n = number.to_i
        super(n, NAMES[n])
      end

      def to_s; "[#{[number, name].compact.join(', ')}]"; end
    end

  end

end
