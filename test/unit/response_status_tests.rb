require 'assert'
require 'sanford-protocol/response_status'

class Sanford::Protocol::ResponseStatus

  class BaseTests < Assert::Context
    desc "Sanford::Protocol::ResponseStatus"
    setup do
      @status = Sanford::Protocol::ResponseStatus.new(200, "OK")
    end
    subject{ @status }

    should have_instance_methods :code, :message, :name

    should "return a code's name with #name, if it has one" do
      named_status = Sanford::Protocol::ResponseStatus.new(200)
      unamed_status = Sanford::Protocol::ResponseStatus.new(999)

      assert_equal "SUCCESS", named_status.name
      assert_equal nil,       unamed_status.name
    end

    should "use a named code's value when it's given when initializing" do
      Sanford::Protocol::ResponseStatus::CODES.each do |name, value|
        status = Sanford::Protocol::ResponseStatus.new(name)

        assert_equal value, status.code
      end
    end

    should "return it's code and name with #to_s" do
      named_status = Sanford::Protocol::ResponseStatus.new(200)
      unamed_status = Sanford::Protocol::ResponseStatus.new(999)

      assert_equal "[#{named_status.code}, #{named_status.name}]", named_status.to_s
      assert_equal "[#{unamed_status.code}]", unamed_status.to_s
    end

  end

end
