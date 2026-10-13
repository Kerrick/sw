# frozen_string_literal: true

require "test_helper"

class TestStarshipsPanel < Minitest::Test
  include ViewTestHelper
  include EntireGalaxy

  def test_lukes_x_wing_is_an_incom_t65_starfighter_for_one_pilot_and_no_passengers
    with_rendered(Sw::Starships::View.call(luke.starships, tui)) do
      assert_text_style "X-wing", modifiers: [:bold]
      assert_text_style "Starfighter", on_line_with: "X-wing", modifiers: []
      refute_nil text_position("1 / 0")
      refute_nil text_position("T-65 X-wing / Incom Corporation")
    end
  end
end
