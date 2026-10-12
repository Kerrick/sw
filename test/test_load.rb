# frozen_string_literal: true

require "test_helper"

class TestLoad < Minitest::Test
  include Rooibos::TestHelper

  KeepLastMessage = -> (message, model) do
    message.ctrl_c? ? [model, Rooibos::Command.exit] : message
  end

  def test_crawling_from_the_root_loads_all_82_characters
    assert_equal 82, finished.characters.count
  end

  def test_crawling_from_the_root_loads_all_39_vehicles
    assert_equal 39, finished.vehicles.count
  end

  def test_a_refused_connection_fails_naming_the_address
    url = unreachable_url
    failed = delivered(url)

    assert_equal "Sw::Load::Failed", failed.class.name
    assert_includes failed.reason, URI(url).authority
  end

  private def finished = delivered(FIXTURE_SERVER.url)

  private def delivered(url)
    with_test_terminal do
      inject_sync
      inject_key(:ctrl_c)
      Rooibos::Runtime.run(model: :loading, view: ClearView, update: KeepLastMessage, command: Sw::Load.new(url:))
    end
  end
end
