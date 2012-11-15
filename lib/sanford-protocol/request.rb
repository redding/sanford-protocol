# The Request class models a specific type of Sanford message body and provides
# a defined structure for it. A request requires a message body to contain a
# version, name and params.

module Sanford::Protocol

  class Request < Struct.new(:version, :name, :params)

    def self.parse(body)
      self.new(body['version'], body['name'], body['params'])
    end

    def to_hash
      { 'version' => version,
        'name'    => name,
        'params'  => params
      }
    end

    def to_s; "[#{version}] #{name}"; end

    def valid?
      if !version
        [ false, "The request doesn't contain a version." ]
      elsif !name
        [ false, "The request doesn't contain a name." ]
      else
        [ true ]
      end
    end

    def inspect
      reference = '0x0%x' % (self.object_id << 1)
      "#<#{self.class}:#{reference}"\
      " @version=#{version.inspect}"\
      " @name=#{name.inspect}"\
      " @params=#{params.inspect}>"
    end

  end

end
