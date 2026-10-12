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
end
