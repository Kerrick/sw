# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "sw"
require "tmpdir"
require "fileutils"
require "rooibos/test_helper"
require_relative "support/fixture_server"
require_relative "support/view_test_helper"
require_relative "support/small_galaxy"
require_relative "support/entire_galaxy"

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

# Every test starts with an empty cache of its own, found the way the app finds the user's: under HOME on macOS,
# XDG_CACHE_HOME on Linux, and LOCALAPPDATA on Windows.
module EmptyCache
  CACHE_HOMES = %w[HOME XDG_CACHE_HOME LOCALAPPDATA].freeze

  def before_setup
    super
    @cache_home = Dir.mktmpdir("sw-cache")
    @user_cache_homes = ENV.slice(*CACHE_HOMES)
    CACHE_HOMES.each { |name| ENV[name] = @cache_home }
  end

  # Dates every cached file to the given time, as if the download had happened then.
  private def age_cache(mtime)
    FileUtils.touch(Dir.glob("**/*.json", base: @cache_home).map { |name| File.join(@cache_home, name) }, mtime:)
  end

  def after_teardown
    CACHE_HOMES.each { |name| ENV[name] = @user_cache_homes[name] }
    FileUtils.remove_entry(@cache_home)
    super
  end
end
Minitest::Test.include(EmptyCache)

# Tests that need a network failure ask for an address nothing listens on.
module UnreachableUrl
  # Windows retries a refused connection for about two seconds, the test terminal's whole default timeout, so a test
  # that waits for the refusal gives it longer.
  REFUSAL_TIMEOUT = 5

  # A port that was open a moment ago and now refuses connections.
  private def unreachable_url
    server = TCPServer.new("127.0.0.1", 0)
    port = server.addr[1]
    server.close
    "http://127.0.0.1:#{port}/api"
  end
end
Minitest::Test.include(UnreachableUrl)
