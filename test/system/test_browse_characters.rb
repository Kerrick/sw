# frozen_string_literal: true

require "test_helper"

class TestBrowseCharacters < Minitest::Test
  include Rooibos::TestHelper

  def test_the_list_shows_ackbar
    with_test_terminal(120, 40) do
      inject_sync
      inject_key(:ctrl_c)
      Rooibos.run(Sw)

      assert_snapshots("the_list_shows_ackbar")
    end
  end

  # Luke is the 43rd of 82, so reaching him also scrolls the list.
  def test_moving_down_from_ackbar_reaches_luke_skywalker
    with_test_terminal(120, 40) do
      inject_sync
      inject_keys(*Array.new(42, :down))
      inject_key(:ctrl_c)
      Rooibos.run(Sw)

      assert_includes buffer_content.join("\n"), "Luke Skywalker"
      assert_snapshots("moving_down_from_ackbar_reaches_luke_skywalker")
    end
  end
end
