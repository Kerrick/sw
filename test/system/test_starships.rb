# frozen_string_literal: true

require "test_helper"

class TestStarships < Minitest::Test
  include Rooibos::TestHelper

  # Luke is the 43rd of 82.
  def test_luke_pilots_an_x_wing_and_an_imperial_shuttle
    with_test_terminal(120, 40) do
      inject_sync
      inject_keys(*Array.new(42, :down))
      inject_key(:ctrl_c)
      Rooibos.run(Sw)

      screen = buffer_content.join("\n")
      assert_includes screen, "X-wing"
      assert_includes screen, "Imperial shuttle"
      assert_snapshots("luke_pilots_an_x_wing_and_an_imperial_shuttle")
    end
  end
end
