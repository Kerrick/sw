# frozen_string_literal: true

require "test_helper"

class TestFirstLaunchWithoutANetwork < Minitest::Test
  include Rooibos::TestHelper

  def test_the_error_screen_names_the_address_it_could_not_reach
    url = unreachable_url
    ENV["SW_API_URL"] = url

    with_test_terminal(120, 40) do
      inject_sync
      inject_key(:ctrl_c)
      Rooibos.run(Sw)

      assert_includes buffer_content.join("\n"), URI(url).authority
      assert_snapshots("first_launch_without_a_network")
    end
  end

  # The port changes every run. Ephemeral ports are five digits, so the mask keeps the width.
  private def normalize_snapshots(lines)
    lines.map { |line| line.gsub(/\b\d{5}\b/, "NNNNN") }
  end
end
