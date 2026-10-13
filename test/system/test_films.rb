# frozen_string_literal: true

require "test_helper"

class TestFilms < Minitest::Test
  include Rooibos::TestHelper
  include ViewTestHelper

  # Luke is the 43rd of 82. The terminal is wide enough for the longest title to fit its column.
  def test_luke_appears_in_episodes_three_through_six
    with_test_terminal(160, 40) do
      inject_sync
      inject_keys(*Array.new(42, :down))
      inject_key(:ctrl_c)
      Rooibos.run(Sw)

      episodes_one_through_six = ["The Phantom Menace", "Attack of the Clones", "Revenge of the Sith", "A New Hope", "The Empire Strikes Back", "Return of the Jedi"]
      columns = episodes_one_through_six.map { |title| text_position(title)&.first }

      assert_equal 6, columns.compact.size
      assert_equal columns.sort, columns
      assert_text_style "The Phantom Menace", modifiers: [:bold, :dim]
      assert_text_style "Attack of the Clones", modifiers: [:bold, :dim]
      assert_text_style "Revenge of the Sith", modifiers: [:bold]
      assert_text_style "A New Hope", modifiers: [:bold]
      assert_text_style "The Empire Strikes Back", modifiers: [:bold]
      assert_text_style "Return of the Jedi", modifiers: [:bold]
      assert_snapshots("luke_appears_in_episodes_three_through_six")
    end
  end
end
