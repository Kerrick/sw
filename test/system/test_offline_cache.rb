# frozen_string_literal: true

require "test_helper"

class TestOfflineCache < Minitest::Test
  include Rooibos::TestHelper
  include ViewTestHelper

  def test_the_second_launch_needs_no_network
    launch
    ENV["SW_API_URL"] = unreachable_url

    launch do
      assert_includes buffer_content.join("\n"), "Ackbar"
    end
  end

  def test_a_week_old_cache_shows_at_once_and_reloads_behind_it
    launch
    eight_days_ago = Time.now - (8 * 24 * 60 * 60)
    age_cache(eight_days_ago)
    never_answers = TCPServer.new("127.0.0.1", 0)
    ENV["SW_API_URL"] = "http://127.0.0.1:#{never_answers.addr[1]}/api"

    launch do
      assert_includes buffer_content.join("\n"), "Ackbar"
      assert_text_style "Reloading", fg: :blue
      assert_snapshots("a_week_old_cache_reloading")
    end
  ensure
    never_answers&.close
  end

  def test_a_week_old_cache_without_a_network_keeps_its_characters_on_screen
    launch
    eight_days_ago = Time.now - (8 * 24 * 60 * 60)
    age_cache(eight_days_ago)
    ENV["SW_API_URL"] = unreachable_url

    with_test_terminal(120, 40) do
      inject_sync # the cache
      inject_sync # the background reload
      inject_key(:ctrl_c)
      Rooibos.run(Sw)

      assert_includes buffer_content.join("\n"), "Ackbar"
      assert_text_style "Reload failed", fg: :red
      assert_snapshots("a_week_old_cache_without_a_network")
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
