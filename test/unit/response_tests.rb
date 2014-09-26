require 'assert'
require 'sanford-protocol/response'

class Sanford::Protocol::Response

  class UnitTests < Assert::Context
    desc "Sanford::Protocol::Response"
    setup do
      @response = Sanford::Protocol::Response.new([ 672, 'YAR!' ], { 'something' => true })
    end
    subject{ @response }

    should have_imeths :status, :data, :to_hash
    should have_imeths :code, :code=, :message, :message=, :to_s
    should have_cmeths :parse

    should "demeter its status" do
      assert_equal subject.status.code, subject.code
      assert_equal subject.status.message, subject.message
      assert_equal subject.status.to_s, subject.to_s

      new_code = Factory.integer
      new_message = Factory.string
      subject.code = new_code
      subject.message = new_message
      assert_equal new_code, subject.code
      assert_equal new_message, subject.message
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

    should "be comparable" do
      match_response = Sanford::Protocol::Response.new(
        subject.status.dup,
        subject.data.dup
      )
      assert_equal match_response, subject

      not_match_response = Sanford::Protocol::Response.new(123, {})
      assert_not_equal not_match_response, subject
    end

  end

  # Somewhat of a system test, want to make sure if Response is passed some
  # "fuzzy" args that it will build it's status object as expected
  class StatusBuildingTests < UnitTests

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

      assert_equal 348, response.status.code
      assert_equal "my message", response.status.message
    end
  end

end
