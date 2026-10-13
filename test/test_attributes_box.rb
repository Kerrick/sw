# frozen_string_literal: true

require "test_helper"

class TestAttributesBox < Minitest::Test
  include ViewTestHelper
  include EntireGalaxy

  def test_luke_is_a_blue_eyed_blond_fair_skinned_male_born_19bby_172_cm_tall_and_77_kg
    with_rendered(Sw::AttributesBox::View.call(luke, tui)) do
      ["19BBY", "male", "172 cm", "77 kg", "blue", "blond", "fair"].each do |value|
        refute_nil text_position(value), "Expected #{value.inspect} on screen"
      end
    end
  end

  def test_anakin_was_born_41_9bby_to_the_tenth_of_a_year
    anakin = character("Anakin Skywalker")

    with_rendered(Sw::AttributesBox::View.call(anakin, tui)) do
      refute_nil text_position("41.9BBY")
    end
  end

  def test_jek_tono_porkins_birth_year_reads_dimmed_as_unknown
    jek_tono_porkins = character("Jek Tono Porkins")

    with_rendered(Sw::AttributesBox::View.call(jek_tono_porkins, tui)) do
      assert_text_style "unknown", modifiers: [:dim]
    end
  end

  def test_jabba_weighs_1_358_kg
    jabba = character("Jabba Desilijic Tiure")

    with_rendered(Sw::AttributesBox::View.call(jabba, tui)) do
      refute_nil text_position("1,358 kg")
    end
  end

  def test_r2_d2s_hair_color_reads_dimmed_because_it_doesnt_apply
    r2_d2 = character("R2-D2")

    with_rendered(Sw::AttributesBox::View.call(r2_d2, tui)) do
      assert_text_style "n/a", on_line_with: "Hair color:", modifiers: [:dim]
    end
  end

  def test_mace_windus_hair_color_of_none_reads_as_a_real_answer
    mace_windu = character("Mace Windu")

    with_rendered(Sw::AttributesBox::View.call(mace_windu, tui)) do
      assert_text_style "none", on_line_with: "Hair color:", modifiers: []
    end
  end

  def test_r2_d2s_gender_reads_dimmed_because_it_doesnt_apply
    r2_d2 = character("R2-D2")

    with_rendered(Sw::AttributesBox::View.call(r2_d2, tui)) do
      assert_text_style "n/a", on_line_with: "Gender:", modifiers: [:dim]
    end
  end

  def test_ig_88s_gender_of_none_reads_as_a_real_answer
    ig_88 = character("IG-88")

    with_rendered(Sw::AttributesBox::View.call(ig_88, tui)) do
      assert_text_style "none", on_line_with: "Gender:", modifiers: []
    end
  end

  def test_tarkins_hair_is_both_auburn_and_grey
    tarkin = character("Wilhuff Tarkin")

    with_rendered(Sw::AttributesBox::View.call(tarkin, tui)) do
      refute_nil text_position("auburn, grey")
    end
  end

  private def character(name) = EntireGalaxy::RECORDS.fetch(:characters).find { |character| character.name.to_s == name }
end
