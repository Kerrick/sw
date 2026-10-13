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

  def test_a_reload_without_a_network_keeps_the_characters_on_screen
    launch
    ENV["SW_API_URL"] = unreachable_url

    launch(:r) do
      assert_includes buffer_content.join("\n"), "Ackbar"
      assert_snapshots("a_reload_without_a_network")
    end
  end

  # Presses each key once the data before it has arrived.
  private def launch(*keys)
    with_test_terminal(120, 40) do
      inject_sync
      keys.each do |key|
        inject_key(key)
        inject_sync
      end
      inject_key(:ctrl_c)
      Rooibos.run(Sw)
      yield if block_given?
    end
  end
end
