module Sanford::Protocol

  class BadMessageError < RuntimeError
    def initialize(message, bt=nil)
      super(message)
      set_backtrace(bt || caller)
    end
  end

  class MsgData
    attr_reader :value

    def initialize(called_from=nil, &get_value)

      # By default, any exceptions from getting the value are "hidden" behind a
      # more general `BadMessageError`. In non-debug scenarios this is ideal and
      # allows you to rescue from a common exception and respond in a standard way.
      # In debug scenarios, however, go ahead and raise the real exception.

      begin
        @value = get_value.call
      rescue Exception => err
        @called_from = called_from || caller
        ENV['SANFORD_PROTOCOL_DEBUG'] ? raise(err) : self.error!(self.get_value_error)
      end
    end

    def get_value_error; "Error reading the message"; end
    def validate!; self; end

    def error!(message)
      raise BadMessageError.new(message, @called_from)
    end

  end

  class MsgSize < MsgData
    def get_value_error; "Error reading message body size."; end
    def validate!
      error!("Empty message size") if self.value.nil?
      super
    end
  end

  class MsgVersion < MsgData
    def get_value_error; "Error reading message protocol version"; end
    def validate!
      error!("Protocol version mismatch") if version_mismatch?
      super
    end

    def version_mismatch?
      self.value != Sanford::Protocol.msg_version
    end
  end

  class MsgBody < MsgData
    def get_value_error; "Error reading message body."; end
  end

end
