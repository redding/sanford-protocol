require 'assert'
require 'sanford-protocol/request'

class Sanford::Protocol::Request

  class BaseTests < Assert::Context
    desc "Sanford::Protocol::Request"
    setup do
      @request = Sanford::Protocol::Request.new('v1', 'some_service', [ true ])
    end
    subject{ @request }

    should have_instance_methods :version, :name, :params, :to_hash, :valid?
    should have_class_methods :parse

    should "return an instance of a Sanford::Protocol::Request given a hash using #parse" do
      # using BSON messages are hashes
      hash = {
        'name'    => 'service_name',
        'version' => 'service_version',
        'params'  => 'service_params'
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
        'params'  => [ true ]
      }

      assert_equal expected, subject.to_hash
    end
  end

  class ValidTests < BaseTests
    desc "valid?"

    should "return true and no message with a valid request" do
      request = Sanford::Protocol::Request.new('name', 'v1', {})
      is_valid, message = request.valid?

      assert_equal true, is_valid
      assert_equal nil, message
    end

    should "return false and a message when there isn't a name" do
      request = Sanford::Protocol::Request.new('v1', nil, {})
      is_valid, message = request.valid?

      assert_equal false, is_valid
      assert_equal "The request doesn't contain a name.", message
    end

    should "return false and a message when there isn't a version" do
      request = Sanford::Protocol::Request.new(nil, 'name', {})
      is_valid, message = request.valid?

      assert_equal false, is_valid
      assert_equal "The request doesn't contain a version.", message
    end
  end

end
