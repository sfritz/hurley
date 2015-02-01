require File.expand_path("../helper", __FILE__)

module Hurley
  class TestTest < TestCase

    def setup
      @stubs = Test.new do |stub|
        stub.get "/a/verboten" do |req|
          [403, {}, ""]
        end
        stub.get("/a") do |req|
          output = %w(fee fi fo fum)
          [200, {}, output.join("\n")]
        end

        stub.get "/c" do |req|
          [200, {}, "all the cs"]
        end
        stub.get("/c/1") do |req|
          [200, {}, "one c"]
        end
      end

      @client = Client.new do |c|
        c.connection = @stubs
      end
    end

    def test_matches_most_specific_handler
      res = @client.get("/a")
      assert_equal 200, res.status_code

      res = @client.get("/a/verboten")
      assert_equal 403, res.status_code

      res = @client.get("/c")
      assert_equal "all the cs", res.body

      res = @client.get("/c/1")
      assert_equal "one c", res.body
    end

    def test_returns_404_if_no_handler_found
      res = @client.get("/a")
      assert_equal 200, res.status_code

      res = @client.get("/b")
      assert_equal 404, res.status_code
    end
  end
end
