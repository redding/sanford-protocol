# The Request class models a specific type of Sanford message body and provides
# a defined structure for it. A request requires a message body to contain a
# name and params.

module Sanford; end
module Sanford::Protocol

  BadRequestError = Class.new(RuntimeError)

  class Request

    def self.parse(body)
      self.new(body['name'], body['params'])
    end

    attr_reader :name, :params

    def initialize(name, params)
      self.validate!(name, params)
      @name, @params = name.to_s, params
    end

    def to_hash
      { 'name'   => name,
        'params' => self.stringify(params)
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
        "The request's params are not a valid BSON document."
      end
      raise(BadRequestError, problem) if problem
    end

    def stringify(object)
      case(object)
      when Hash
        object.inject({}){|h, (k, v)| h.merge({ k.to_s => self.stringify(v) }) }
      when Array
        object.map{|item| self.stringify(item) }
      else
        object
      end
    end

  end

end
