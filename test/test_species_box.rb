# frozen_string_literal: true

require "test_helper"

class TestSpeciesBox < Minitest::Test
  include ViewTestHelper
  include EntireGalaxy

  def test_humans_are_sentient_mammals_180_cm_tall_who_live_120_years_and_speak_galactic_basic
    human = EntireGalaxy::RECORDS.fetch(:species).find { |species| species.name.to_s == "Human" }

    with_rendered(Sw::SpeciesBox::View.call(human, tui)) do
      assert_text_style "Human", modifiers: [:bold]
      ["mammal", "sentient", "180 cm", "120 yr", "Galactic Basic"].each do |value|
        refute_nil text_position(value), "Expected #{value.inspect} on screen"
      end
    end
  end

  def test_droids_live_indefinitely_with_no_years_to_count
    droid = EntireGalaxy::RECORDS.fetch(:species).find { |species| species.name.to_s == "Droid" }

    with_rendered(Sw::SpeciesBox::View.call(droid, tui)) do
      refute_nil text_position("indefinite")
      assert_nil text_position("indefinite yr")
    end
  end

  def test_lukes_species_reads_dimmed_as_unknown
    lukes_species = luke.species.first

    with_rendered(Sw::SpeciesBox::View.call(lukes_species, tui)) do
      assert_text_style Sw::SpeciesBox::UNKNOWN, modifiers: [:dim]
    end
  end
end
