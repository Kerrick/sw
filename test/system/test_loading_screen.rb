# frozen_string_literal: true

require "test_helper"

class TestLoadingScreen < Minitest::Test
  include Rooibos::TestHelper

  def test_a_download_that_never_answers_shows_the_loading_screen
    server = TCPServer.new("127.0.0.1", 0)
    ENV["SW_API_URL"] = "http://127.0.0.1:#{server.addr[1]}/api"

    with_test_terminal(120, 40) do
      inject_key(:ctrl_c)
      Rooibos.run(Sw)

      assert_snapshots("loading_screen")
    end
  ensure
    server&.close
  end
end
