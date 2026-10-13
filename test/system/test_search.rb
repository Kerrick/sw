# frozen_string_literal: true

require "test_helper"

class TestSearch < Minitest::Test
  include Rooibos::TestHelper

  def test_sky_finds_luke_anakin_and_shmi_skywalker
    with_test_terminal(120, 40) do
      inject_sync
      inject_keys("/", "s", "k", "y")
      inject_key(:ctrl_c)
      Rooibos.run(Sw)

      screen = buffer_content.join("\n")
      %w[Luke Anakin Shmi].each { |name| assert_includes screen, "#{name} Skywalker" }
      refute_includes screen, "Ackbar"
      assert_snapshots("a_search_for_sky")
    end
  end

  def test_a_search_for_grogu_shows_grogu_in_search_and_in_the_list
    with_test_terminal(120, 40) do
      inject_sync
      inject_keys("/", "G", "r", "o", "g", "u")
      inject_key(:ctrl_c)
      Rooibos.run(Sw)

      assert_equal 2, buffer_content.join("\n").scan("Grogu").size
      assert_snapshots("a_search_for_grogu")
    end
  end
end
