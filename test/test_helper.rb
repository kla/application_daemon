ENV["TEST"] = "true"
require "minitest/autorun"
require "minitest/pride"
require_relative "../lib/application_daemon"

class TestCase < Minitest::Spec
end
