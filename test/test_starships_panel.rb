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

  # The panel's width in a 120×40 terminal.
  def test_the_panel_is_tall_enough_for_obi_wan_kenobis_five_starships_in_full
    characters = EntireGalaxy::RECORDS.fetch(:characters)
    obi_wan = characters.find { |character| character.name.to_s == "Obi-Wan Kenobi" }
    belbullab_22_model = "Belbullab-22 starfighter"

    with_rendered(Sw::Starships::View.call(obi_wan.starships, tui), width: 60, height: Sw::Craft::Height.call(characters)) do
      refute_nil text_position(belbullab_22_model, on_line_with: "Model / Manufacturer:")
    end
  end

  def test_ackbar_who_pilots_no_starship_sees_a_dimmed_empty_state
    ackbars_starships = Sw::Collection.new([])

    with_rendered(Sw::Starships::View.call(ackbars_starships, tui)) do
      assert_text_style Sw::Starships::EMPTY, modifiers: [:dim]
    end
  end

  def test_the_aa9_coruscant_freighter_crew_is_dimmed_as_unknown_beside_its_30_000_passengers
    aa9_coruscant_freighter = EntireGalaxy::RECORDS.fetch(:starships).find { |starship| starship.name.to_s == "AA-9 Coruscant freighter" }

    with_rendered(Sw::Starships::View.call(Sw::Collection.new([aa9_coruscant_freighter]), tui)) do
      assert_text_style "unknown", on_line_with: "30,000", modifiers: [:dim]
      assert_text_style "30,000", modifiers: []
    end
  end
end
