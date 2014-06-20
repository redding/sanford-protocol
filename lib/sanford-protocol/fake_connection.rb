module Sanford; end
module Sanford::Protocol

  class FakeConnection

    attr_accessor :read_data, :peek_data, :write_data
    attr_accessor :closed, :closed_write
    attr_reader :read_timeout, :peek_timeout

    def initialize(read_data = nil)
      @read_data  = read_data || ""
      @peek_data  = read_data ? read_data[1] : ""
      @write_data = nil

      @read_timeout = nil
      @peek_timeout = nil

      @closed = false
      @closed_write = false
    end

    def read(timeout = nil)
      @read_timeout = timeout
      @read_data
    end

    def write(data)
      @write_data = data
    end

    def peek(timeout = nil)
      @peek_timeout = timeout
      @peek_data
    end

    def close
      @closed = true
    end

    def close_write
      @closed_write = true
    end

  end

end
