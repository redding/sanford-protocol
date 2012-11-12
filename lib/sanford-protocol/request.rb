# The Request class models a specific type of Sanford message body and provides
# a defined structure for it. A request requires a message body to contain a
# version, name and params. It provides methods for working with message bodies
# (hashes) with `parse` and `to_hash`. In addition to this, a request has a
# `valid?` method, that returns whether it is valid and if it isn't why.
#
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
      { 'version' => self.version,
        'name'    => self.name,
        'params'  => self.params
      }
    end

    def valid?
      if !self.name
        [ false, "The request doesn't contain a name." ]
      elsif !self.version
        [ false, "The request doesn't contain a version." ]
      else
        [ true ]
      end
    end

    def inspect
      reference = '0x0%x' % (self.object_id << 1)
      "#<#{self.class}:#{reference} @name=#{self.name.inspect} " \
      "@version=#{self.version.inspect} @params=#{self.params.inspect}>"
    end

  end

end
