# frozen_string_literal: true

require "test_helper"

class TestOfflineCache < Minitest::Test
  include Rooibos::TestHelper

  def test_the_second_launch_needs_no_network
    launch
    ENV["SW_API_URL"] = unreachable_url

    launch do
      assert_includes buffer_content.join("\n"), "Ackbar"
    end
  end

  private def launch
    with_test_terminal(120, 40) do
      inject_sync
      inject_key(:ctrl_c)
      Rooibos.run(Sw)
      yield if block_given?
    end
  end
end
