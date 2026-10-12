# frozen_string_literal: true

require "test_helper"

class TestSearch < Minitest::Test
  include Rooibos::TestHelper

  def test_sky_finds_luke_anakin_and_shmi_skywalker
    with_test_terminal(120, 40) do
      inject_sync
      inject_keys("/", "s", "k", "y")
      inject_key(:ctrl_c)
      Rooibos.run(Sw)

      screen = buffer_content.join("\n")
      %w[Luke Anakin Shmi].each { |name| assert_includes screen, "#{name} Skywalker" }
      refute_includes screen, "Ackbar"
      assert_snapshots("a_search_for_sky")
    end
  end
end
