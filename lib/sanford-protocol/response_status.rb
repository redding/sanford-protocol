# The Response Status class models a code and optional message. This makes up
# part of a response and provides methods for building and displaying statuses.

module Sanford::Protocol
  class ResponseStatus < Struct.new(:code_obj, :message)

    def initialize(code, message = nil)
      super(Code.new(code), message)
    end

    def code; code_obj.number; end
    alias_method :to_i, :code

    def name; code_obj.name;   end
    def to_s; code_obj.to_s;   end

    def inspect
      reference = '0x0%x' % (self.object_id << 1)
      "#<#{self.class}:#{reference} @code=#{code_obj} @message=#{message.inspect}>"
    end

    class Code < Struct.new(:number, :name)
      NUMBERS = {
        'ok'          => 200,
        'bad_request' => 400,
        'not_found'   => 404,
        'timeout'     => 408,
        'error'       => 500
      }.freeze

      def initialize(key)
        num  = NUMBERS[key.to_s]  || key.to_i
        name = NUMBERS.index(num) || NoName
        super(num, name.upcase)
      end

      def to_s; "[#{[number, name].compact.join(', ')}]"; end

      class NoName
        def self.upcase; nil; end
      end
    end

  end
end
