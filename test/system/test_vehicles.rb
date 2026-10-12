# frozen_string_literal: true

require "test_helper"

class TestVehicles < Minitest::Test
  include Rooibos::TestHelper

  # Luke is the 43rd of 82.
  def test_luke_pilots_a_snowspeeder_and_an_imperial_speeder_bike
    with_test_terminal(120, 40) do
      inject_sync
      inject_keys(*Array.new(42, :down))
      inject_key(:ctrl_c)
      Rooibos.run(Sw)

      screen = buffer_content.join("\n")
      assert_includes screen, "Snowspeeder"
      assert_includes screen, "Imperial Speeder Bike"
      assert_snapshots("luke_pilots_a_snowspeeder_and_an_imperial_speeder_bike")
    end
  end
end
