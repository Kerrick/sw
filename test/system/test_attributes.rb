# frozen_string_literal: true

require "test_helper"

class TestAttributes < Minitest::Test
  include Rooibos::TestHelper

  # Jabba is the 32nd of 82.
  def test_jabba_weighs_1_358_kg
    with_test_terminal(120, 40) do
      inject_sync
      inject_keys(*Array.new(31, :down))
      inject_key(:ctrl_c)
      Rooibos.run(Sw)

      jabba_mass = "1,358 kg"
      assert_includes buffer_content.join("\n"), jabba_mass
      assert_snapshots("jabba_weighs_1_358_kg")
    end
  end
end
