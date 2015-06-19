require 'sanford-protocol'

module Sanford; end
module Sanford::Protocol

  class Request

    def self.parse(body)
      self.new(body['name'], body['params'])
    end

    attr_reader :name, :params

    def initialize(name, params)
      self.validate!(name, params)
      @name   = name.to_s
      @params = params
    end

    def to_hash
      { 'name'   => name,
        'params' => Sanford::Protocol::StringifyParams.new(params)
      }
    end

    def to_s; name; end

    def inspect
      reference = '0x0%x' % (self.object_id << 1)
      "#<#{self.class}:#{reference}"\
      " @name=#{name.inspect}"\
      " @params=#{params.inspect}>"
    end

    def ==(other)
      if other.kind_of?(self.class)
        self.to_hash == other.to_hash
      else
        super
      end
    end

    protected

    def validate!(name, params)
      problem = if !name
        "The request doesn't contain a name."
      elsif !params.kind_of?(::Hash)
        "The request's params are not valid."
      end
      raise(InvalidError, problem) if problem
    end

    InvalidError = Class.new(ArgumentError)

  end

end
