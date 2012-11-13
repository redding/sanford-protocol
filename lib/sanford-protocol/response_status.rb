# The Response Status class models a code and optional message. This makes up
# part of a response and provides methods for building and displaying statuses.

module Sanford::Protocol

  class ResponseStatus < Struct.new(:code, :message)

    CODES = {
      :success      => 200,
      :bad_request  => 400,
      :not_found    => 404,
      :error        => 500
    }.freeze

    def initialize(code, message = nil)
      code_number = CODES[code.to_sym] || code.to_i
      super(code_number, message)
    end

    def name
      key = CODES.index(self.code)
      key.to_s.upcase if key
    end

    def to_s
      "[#{[ code, name ].compact.join(', ')}]"
    end

    def inspect
      msg = self.message if self.message && !self.message.empty?
      [ self.code, self.name, msg ].compact.inspect
    end

  end

end
