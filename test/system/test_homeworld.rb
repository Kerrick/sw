# frozen_string_literal: true

require "test_helper"

class TestHomeworld < Minitest::Test
  include Rooibos::TestHelper

  # Luke is the 43rd of 82.
  def test_luke_is_from_tatooine
    with_test_terminal(120, 40) do
      inject_sync
      inject_keys(*Array.new(42, :down))
      inject_key(:ctrl_c)
      Rooibos.run(Sw)

      screen = buffer_content.join("\n")
      tatooine_population = "200,000"
      assert_includes screen, "Tatooine"
      assert_includes screen, tatooine_population
      assert_snapshots("luke_is_from_tatooine")
    end
  end
end
