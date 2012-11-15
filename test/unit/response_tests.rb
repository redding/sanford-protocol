require 'assert'
require 'sanford-protocol/response'

class Sanford::Protocol::Response

  class BaseTests < Assert::Context
    desc "Sanford::Protocol::Response"
    setup do
      @response = Sanford::Protocol::Response.new([ 672, 'YAR!' ], { 'something' => true })
    end
    subject{ @response }

    should have_instance_methods :status, :code, :data, :to_hash, :to_s
    should have_class_methods :parse

    should "return its status#code with #code" do
      assert_equal subject.status.code, subject.code
    end

    should "return its status#to_s with #to_s" do
      assert_equal subject.status.to_s, subject.to_s
    end

    should "return an instance of a Sanford::Protocol::Response given a hash using #parse" do
      # using BSON messages are hashes
      hash = {
        'status' => [ 200, 'OK' ],
        'data'   => 'yes'
      }
      request = Sanford::Protocol::Response.parse(hash)

      assert_instance_of Sanford::Protocol::Response, request
      assert_equal hash['status'].first, request.status.code
      assert_equal hash['status'].last,  request.status.message
      assert_equal hash['data'],         request.data
    end

    should "return the request as a hash with #to_hash" do
      # using BSON messages are hashes
      expected = {
        'status' => [ 672, 'YAR!' ],
        'data'   => { 'something' => true }
      }

      assert_equal expected, subject.to_hash
    end

  end

  # Somewhat of a system test, want to make sure if Response is passed some
  # "fuzzy" args that it will build it's status object as expected
  class StatusBuildingTests < BaseTests

    should "build a status with it's code set, given an integer" do
      response = Sanford::Protocol::Response.new(574)

      assert_equal 574, response.status.code
      assert_equal nil, response.status.message
    end

    should "build a status with it's code set, given a name" do
      response = Sanford::Protocol::Response.new('ok')

      assert_equal 200, response.status.code
      assert_equal nil, response.status.message
    end

    should "use a status object, if given one" do
      status = Sanford::Protocol::ResponseStatus.new(200, "OK")
      response = Sanford::Protocol::Response.new(status)

      assert_same status, response.status
    end

    should "build a status with a code and message set, when given both" do
      response = Sanford::Protocol::Response.new([ 348, "my message" ])

      assert_equal 348,           response.status.code
      assert_equal "my message",  response.status.message
    end
  end

end
