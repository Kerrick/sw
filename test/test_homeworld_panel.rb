# frozen_string_literal: true

require "test_helper"

class TestHomeworldPanel < Minitest::Test
  include ViewTestHelper
  include EntireGalaxy

  def test_lukes_homeworld_tatooine_is_a_desert_of_200_000_people
    with_rendered(Sw::Homeworld::View.call(luke.homeworld, tui)) do
      assert_text_style "Tatooine", modifiers: [:bold]
      ["200,000", "desert", "arid", "1%", "10,465 km", "23 hr", "304 d", "1 standard"].each do |value|
        refute_nil text_position(value), "Expected #{value.inspect} on screen"
      end
    end
  end
end
