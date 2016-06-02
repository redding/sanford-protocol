require 'assert'
require 'sanford-protocol/response_status'

class Sanford::Protocol::ResponseStatus

  class UnitTests < Assert::Context
    desc "Sanford::Protocol::ResponseStatus"
    setup do
      @status_class = Sanford::Protocol::ResponseStatus
      @code = Factory.integer
      @msg  = Factory.string
      @status = @status_class.new(@code, @msg)
    end
    subject{ @status }

    should have_readers :code_obj, :message
    should have_imeths :code, :code=, :name, :to_i

    should "know its code obj and message" do
      assert_kind_of Code, subject.code_obj
      assert_equal @code,  subject.code_obj.number
      assert_equal @msg,   subject.message
    end

    should "know its code numbers" do
      assert_equal subject.code_obj.number, subject.code
      assert_equal subject.code,            subject.to_i

      assert_equal 0, @status_class.new(Factory.string).code
    end

    should "know its code names" do
      assert_equal subject.code_obj.name, subject.name

      assert_equal 'OK',          @status_class.new(200).name
      assert_equal 'BAD REQUEST', @status_class.new(400).name
      assert_equal 'NOT FOUND',   @status_class.new(404).name
      assert_equal 'TIMEOUT',     @status_class.new(408).name
      assert_equal 'INVALID',     @status_class.new(422).name
      assert_equal 'ERROR',       @status_class.new(500).name
      assert_equal nil,           @status_class.new(Factory.integer+500).name
    end

    should "allow setting its code" do
      number = [200, 400, 404, 408, 422, 500].sample
      subject.code = number

      exp_status = @status_class.new(number)
      assert_equal exp_status.code, subject.code
      assert_equal exp_status.name, subject.name
    end

    should "return its code number and code name with #to_s" do
      named = @status_class.new([200, 400, 404, 408, 422, 500].sample)
      assert_equal "[#{named.code}, #{named.name}]", named.to_s

      unamed = @status_class.new(Factory.integer+500)
      assert_equal "[#{unamed.code}]", unamed.to_s
    end

  end

end
