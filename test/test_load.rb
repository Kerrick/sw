# frozen_string_literal: true

require "test_helper"

class TestLoad < Minitest::Test
  include Rooibos::TestHelper

  KeepLastMessage = -> (message, model) do
    message.ctrl_c? ? [model, Rooibos::Command.exit] : message
  end

  def test_crawling_from_the_root_loads_all_82_characters
    assert_equal 82, loaded.characters.count
  end

  def test_crawling_from_the_root_loads_all_39_vehicles
    assert_equal 39, loaded.vehicles.count
  end

  private def loaded
    with_test_terminal do
      inject_sync
      inject_key(:ctrl_c)
      Rooibos::Runtime.run(model: :loading, view: ClearView, update: KeepLastMessage, command: Sw::Load.new(url: FIXTURE_SERVER.url))
    end
  end
end
