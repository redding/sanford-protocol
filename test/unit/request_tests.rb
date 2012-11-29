require 'assert'
require 'sanford-protocol/request'

class Sanford::Protocol::Request

  class BaseTests < Assert::Context
    desc "Sanford::Protocol::Request"
    setup do
      @request = Sanford::Protocol::Request.new('v1', 'some_service', { 'key' => 'value' })
    end
    subject{ @request }

    should have_instance_methods :version, :name, :params, :to_hash
    should have_class_methods :parse

    should "return it's version and name with #to_s" do
      assert_equal "[#{subject.version}] #{subject.name}", subject.to_s
    end

    should "stringify params keys" do
      request = Sanford::Protocol::Request.new('v1', 'service', {
        1       => 1,
        :symbol => :symbol
      })
      expected = { "1" => 1, "symbol" => :symbol }
      assert_equal expected, request.params
    end

    should "return an instance of a Sanford::Protocol::Request given a hash using #parse" do
      # using BSON messages are hashes
      hash = {
        'name'    => 'service_name',
        'version' => 'service_version',
        'params'  => { 'service_params' => 'yes' }
      }
      request = Sanford::Protocol::Request.parse(hash)

      assert_instance_of Sanford::Protocol::Request, request
      assert_equal hash['name'],     request.name
      assert_equal hash['version'],  request.version
      assert_equal hash['params'],   request.params
    end

    should "return the request as a hash with #to_hash" do
      # using BSON messages are hashes
      expected = {
        'version' => 'v1',
        'name'    => 'some_service',
        'params'  => { 'key' => 'value' }
      }

      assert_equal expected, subject.to_hash
    end
  end

  class ValidTests < BaseTests

    should "not raise an exception with valid request args" do
      assert_nothing_raised do
        Sanford::Protocol::Request.new('v1', 'name', {})
      end
    end

    should "raise an exception when there isn't a name arg" do
      assert_raises(Sanford::Protocol::BadRequestError) do
        Sanford::Protocol::Request.new('v1', nil, {})
      end
    end

    should "return false and a message when there isn't a version" do
      assert_raises(Sanford::Protocol::BadRequestError) do
        Sanford::Protocol::Request.new(nil, 'name', {})
      end
    end

    should "return false and a message when the params are not a Hash" do
      assert_raises(Sanford::Protocol::BadRequestError) do
        Sanford::Protocol::Request.new('v1', 'name', true)
      end
    end
  end

end
