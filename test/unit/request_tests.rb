require 'assert'
require 'sanford-protocol/request'

class Sanford::Protocol::Request

  class UnitTests < Assert::Context
    desc "Sanford::Protocol::Request"
    setup do
      @name   = Factory.string
      @params = { Factory.string => Factory.string }
      @request_class = Sanford::Protocol::Request
    end
    subject{ @request_class }

    should have_imeths :parse

    should "parse a request from a body hash" do
      request = @request_class.parse({
        'name'   => @name,
        'params' => @params
      })

      assert_instance_of @request_class, request
      assert_equal @name,   request.name
      assert_equal @params, request.params
    end

  end

  class InitTests < UnitTests
    desc "when init"
    setup do
      @request = @request_class.new(@name, @params)
    end
    subject{ @request }

    should have_imeths :name, :params, :to_hash

    should "know its name and params" do
      assert_equal @name,   subject.name
      assert_equal @params, subject.params
    end

    should "force string request names" do
      request = @request_class.new(@name.to_sym, {})
      assert_equal @name, request.name
    end

    should "return its name using `to_s`" do
      assert_equal subject.name, subject.to_s
    end

    should "return the request as a hash using `to_hash`" do
      @params[Factory.integer]       = Factory.integer
      @params[Factory.string.to_sym] = Factory.string.to_sym
      request = @request_class.new(@name, @params)
      exp = {
        'name'   => @name,
        'params' => Sanford::Protocol::StringifyParams.new(@params)
      }
      assert_equal exp, request.to_hash
    end

    should "be comparable" do
      matching = @request_class.new(@name, @params)
      assert_equal matching, subject

      non_matching = @request_class.new(Factory.string, @params)
      assert_not_equal non_matching, subject
      non_matching = @request_class.new(@name, Factory.string => Factory.string)
      assert_not_equal non_matching, subject
    end

    should "raise an error when given invalid attributes" do
      assert_raises(InvalidError){ @request_class.new(nil, @params) }
      assert_raises(InvalidError){ @request_class.new(@name, Factory.string) }
    end

  end

end
