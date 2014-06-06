require 'assert'
require 'sanford-protocol/response_status'

class Sanford::Protocol::ResponseStatus

  class UnitTests < Assert::Context
    desc "Sanford::Protocol::ResponseStatus"
    setup do
      @status = Sanford::Protocol::ResponseStatus.new(200, "OK")
    end
    subject{ @status }

    should have_readers :code_obj, :message
    should have_imeths :code, :name, :to_i

    should "know it's code name" do
      named  = Sanford::Protocol::ResponseStatus.new(200)
      unamed = Sanford::Protocol::ResponseStatus.new(999)

      assert_equal "OK", named.name
      assert_equal nil,  unamed.name
    end

    should "know it's code number" do
      Code::NUMBERS.each do |name, value|
        status = Sanford::Protocol::ResponseStatus.new(name)
        assert_equal value, status.code
      end

      unamed = Sanford::Protocol::ResponseStatus.new('unamed')
      assert_equal 0, unamed.code
    end

    should "return it's code number with #to_i" do
      assert_equal subject.code, subject.to_i
    end

    should "return it's code number and code name with #to_s" do
      named  = Sanford::Protocol::ResponseStatus.new(200)
      unamed = Sanford::Protocol::ResponseStatus.new(999)

      assert_equal "[#{named.code}, #{named.name}]", named.to_s
      assert_equal "[#{unamed.code}]", unamed.to_s
    end

  end

end
