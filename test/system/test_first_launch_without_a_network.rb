# frozen_string_literal: true

require "test_helper"

class TestFirstLaunchWithoutANetwork < Minitest::Test
  include Rooibos::TestHelper

  def test_the_error_screen_names_the_address_it_could_not_reach
    url = unreachable_url
    ENV["SW_API_URL"] = url

    with_test_terminal(120, 40, timeout: REFUSAL_TIMEOUT) do
      inject_sync
      inject_key(:ctrl_c)
      Rooibos.run(Sw)

      assert_includes buffer_content.join("\n"), URI(url).authority
      assert_snapshots("first_launch_without_a_network")
    end
  end

  # The port changes every run. Ephemeral ports are five digits, so the mask keeps the width. The operating system words
  # the refusal itself, at its own length, so the reason wraps onto as many rows as it needs: the mask covers it from its
  # parenthesis to the bottom of the box.
  private def normalize_snapshots(lines)
    in_reason = false
    lines.map do |line|
      line = line.gsub(/\b\d{5}\b/, "NNNNN")
      if line.include?("Failed to open TCP connection")
        in_reason = true
        line.sub(/ \(.*(?=│)/) { |reason| " (the OS's reason)".ljust(reason.length) }
      elsif in_reason && line.include?("└")
        in_reason = false
        line
      elsif in_reason
        line.sub(/(?<=│).*(?=│)/) { |inside| " " * inside.length }
      else
        line
      end
    end
  end
end
