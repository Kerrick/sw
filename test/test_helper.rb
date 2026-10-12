# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "sw"
require "rooibos/test_helper"
require_relative "support/fixture_server"

require "minitest/autorun"

# Every test talks to the recorded API, never to swapi.info.
FIXTURE_SERVER = FixtureServer.new
Minitest.after_run { FIXTURE_SERVER.close }

# Every test starts pointed at the fixture server, whatever earlier tests set.
module PointAtFixtureServer
  def before_setup
    super
    ENV["SW_API_URL"] = FIXTURE_SERVER.url
  end
end
Minitest::Test.include(PointAtFixtureServer)
