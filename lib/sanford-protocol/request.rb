# The Request class models a specific type of Sanford message body and provides
# a defined structure for it. A request requires a message body to contain a
# version, name and params. It provides methods for working with message bodies
# (hashes) with `parse` and `to_hash`. In addition to this, a request has a
# `valid?` method, that returns whether it is valid and if it isn't why.

module Sanford::Protocol

  class Request

    def self.parse(body)
      self.new(body['version'], body['name'], body['params'])
    end

    attr_reader :version, :name, :params

    def initialize(version, name, params)
      @version, @name, @params = version, name, params
    end

    def to_hash
      { 'version' => @version,
        'name'    => @name,
        'params'  => @params
      }
    end

    def valid?
      if !@version
        [ false, "The request doesn't contain a version." ]
      elsif !@name
        [ false, "The request doesn't contain a name." ]
      else
        [ true ]
      end
    end

    def inspect
      reference = '0x0%x' % (self.object_id << 1)
      "#<#{self.class}:#{reference}"\
      " @version=#{@version.inspect}"\
      " @name=#{@name.inspect}"\
      " @params=#{@params.inspect}>"
    end

  end

end
