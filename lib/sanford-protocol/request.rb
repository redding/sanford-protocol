# The Request class models a specific type of Sanford message body and provides
# a defined structure for it. A request requires a message body to contain a
# version, name and params.

module Sanford::Protocol

  BadRequestError = Class.new(RuntimeError)

  class Request

    def self.parse(body)
      self.new(body['version'], body['name'], body['params'])
    end

    attr_reader :version, :name, :params

    def initialize(version, name, params)
      self.validate!(version, name, params)
      @version, @name, @params = version, name, self.stringify(params)
    end

    def to_hash
      { 'version' => version,
        'name'    => name,
        'params'  => params
      }
    end

    def to_s; "[#{version}] #{name}"; end

    def inspect
      reference = '0x0%x' % (self.object_id << 1)
      "#<#{self.class}:#{reference}"\
      " @version=#{version.inspect}"\
      " @name=#{name.inspect}"\
      " @params=#{params.inspect}>"
    end

    protected

    def validate!(version, name, params)
      problem = if !version
        "The request doesn't contain a version."
      elsif !name
        "The request doesn't contain a name."
      elsif !params.kind_of?(Hash)
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
