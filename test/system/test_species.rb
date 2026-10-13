# frozen_string_literal: true

require "test_helper"

class TestSpecies < Minitest::Test
  include Rooibos::TestHelper
  include ViewTestHelper

  # Luke is the 43rd of 82.
  def test_lukes_species_is_unknown
    with_test_terminal(120, 40) do
      inject_sync
      inject_keys(*Array.new(42, :down))
      inject_key(:ctrl_c)
      Rooibos.run(Sw)

      assert_text_style Sw::SpeciesBox::UNKNOWN, modifiers: [:dim]
      assert_snapshots("lukes_species_is_unknown")
    end
  end
end
