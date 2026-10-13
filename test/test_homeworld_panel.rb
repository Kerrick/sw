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

  def test_iridonias_unknown_diameter_reads_dimmed_with_no_kilometers
    iridonia = EntireGalaxy::RECORDS.fetch(:planets).find { |planet| planet.name.to_s == "Iridonia" }

    with_rendered(Sw::Homeworld::View.call(iridonia, tui)) do
      assert_nil text_position("unknown km")
      assert_text_style "unknown", modifiers: [:dim]
    end
  end

  def test_dagobahs_gravity_of_n_a_reads_dimmed
    dagobah = EntireGalaxy::RECORDS.fetch(:planets).find { |planet| planet.name.to_s == "Dagobah" }

    with_rendered(Sw::Homeworld::View.call(dagobah, tui)) do
      assert_text_style "N/A", modifiers: [:dim]
    end
  end

  def test_yodas_homeworld_reads_dimmed_as_unknown_rather_than_as_a_planet_named_unknown
    yoda = EntireGalaxy::RECORDS.fetch(:characters).find { |character| character.name.to_s == "Yoda" }

    with_rendered(Sw::Homeworld::View.call(yoda.homeworld, tui)) do
      assert_text_style Sw::Homeworld::UNKNOWN, modifiers: [:dim]
    end
  end
end
