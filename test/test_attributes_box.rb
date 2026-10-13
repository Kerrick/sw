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
end
