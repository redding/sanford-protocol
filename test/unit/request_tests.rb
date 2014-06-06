require 'assert'
require 'sanford-protocol/request'

class Sanford::Protocol::Request

  class UnitTests < Assert::Context
    desc "Sanford::Protocol::Request"
    setup do
      @request = Sanford::Protocol::Request.new('some_service', { 'key' => 'value' })
    end
    subject{ @request }

    should have_imeths :name, :params, :to_hash
    should have_cmeths :parse

    should "know its name and params" do
      assert_equal 'some_service', subject.name
      assert_equal({ 'key' => 'value' }, subject.params)
    end

    should "force string request names" do
      request = Sanford::Protocol::Request.new(:symbol_service_name, {})
      assert_equal 'symbol_service_name', request.name
    end

    should "return it's name with #to_s" do
      assert_equal subject.name, subject.to_s
    end

    should "parse requests given a body hash" do
      # using BSON messages are hashes
      hash = {
        'name'   => 'service_name',
        'params' => { 'service_params' => 'yes' }
      }
      request = Sanford::Protocol::Request.parse(hash)

      assert_instance_of Sanford::Protocol::Request, request
      assert_equal hash['name'],   request.name
      assert_equal hash['params'], request.params
    end

    should "return the request as a hash with stringified params with #to_hash" do
      # using BSON, messages are hashes
      request = Sanford::Protocol::Request.new('service', {
        1 => 1,
        :symbol => :symbol
      })
      expected = {
        'name'   => 'service',
        'params' => { '1' => 1, 'symbol' => :symbol }
      }
      assert_equal expected, request.to_hash
    end

  end

  class ValidTests < UnitTests

    should "not raise an exception with valid request args" do
      assert_nothing_raised do
        Sanford::Protocol::Request.new('name', {})
      end
    end

    should "raise an exception when there isn't a name arg" do
      assert_raises(Sanford::Protocol::BadRequestError) do
        Sanford::Protocol::Request.new(nil, {})
      end
    end

    should "return false and a message when the params are not a Hash" do
      assert_raises(Sanford::Protocol::BadRequestError) do
        Sanford::Protocol::Request.new('name', true)
      end
    end
  end

end
