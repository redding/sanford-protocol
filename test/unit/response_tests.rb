require 'assert'
require 'sanford-protocol/response'

class Sanford::Protocol::Response

  class UnitTests < Assert::Context
    desc "Sanford::Protocol::Response"
    setup do
      @num  = Factory.integer+500
      @msg  = Factory.string
      @data = { Factory.string => Factory.string }

      @response_class = Sanford::Protocol::Response
      @response = @response_class.new([@num, @msg], @data)
    end
    subject{ @response }

    should have_cmeths :parse
    should have_imeths :status, :data
    should have_imeths :code, :code=, :message, :message=
    should have_imeths :to_s, :to_hash

    should "know its status and data" do
      assert_equal @num,  subject.status.code
      assert_equal @msg,  subject.status.message
      assert_equal @data, subject.data
    end

    should "demeter its status" do
      assert_equal subject.status.code,    subject.code
      assert_equal subject.status.message, subject.message
      assert_equal subject.status.to_s,    subject.to_s

      subject.code    = new_code = Factory.integer
      subject.message = new_msg  = Factory.string
      assert_equal new_code, subject.code
      assert_equal new_msg,  subject.message
    end

    should "know its hash representation" do
      # BSON messages are hashes
      exp = {
        'status' => [@num, @msg],
        'data'   => @data
      }
      assert_equal exp, subject.to_hash
    end

    should "should parse hash representations into objects" do
      # BSON messages are hashes
      hash = {
        'status' => [Factory.integer, Factory.string],
        'data'   => Factory.string
      }
      response = @response_class.parse(hash)

      assert_instance_of @response_class, response
      assert_equal hash['status'].first, response.status.code
      assert_equal hash['status'].last,  response.status.message
      assert_equal hash['data'],         response.data
    end

    should "know if it is equal to another response" do
      equal = @response_class.new(subject.status.dup, subject.data.dup)
      assert_equal equal, subject

      not_equal = @response_class.new(Factory.integer, subject.data.dup)
      assert_not_equal not_equal, subject

      not_equal = @response_class.new(subject.status.dup, {})
      assert_not_equal not_equal, subject
    end

  end

  # Somewhat of a system test, want to make sure if Response is passed some
  # "fuzzy" args that it will build its status object as expected
  class StatusBuildingTests < UnitTests

    should "build a status with its code set if given an integer" do
      response = Sanford::Protocol::Response.new(@num)

      assert_equal @num, response.status.code
      assert_equal nil,  response.status.message
    end

    should "use a status object, if given one" do
      status   = Sanford::Protocol::ResponseStatus.new(@num, @msg)
      response = Sanford::Protocol::Response.new(status)
      assert_same status, response.status
    end

    should "build a status with a code and message set, when given both" do
      response = Sanford::Protocol::Response.new([@num, @msg])

      assert_equal @num, response.status.code
      assert_equal @msg, response.status.message
    end

  end

end
