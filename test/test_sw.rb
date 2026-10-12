# frozen_string_literal: true

require "test_helper"

class TestSw < Minitest::Test
  def test_init_loads_from_the_root_in_sw_api_url
    ENV["SW_API_URL"] = "http://localhost:3000/api"

    _, command = Sw::Init.call

    assert_equal Sw::Load.new(url: "http://localhost:3000/api"), command
  end

  def test_init_loads_from_swapi_info_by_default
    ENV.delete("SW_API_URL")

    _, command = Sw::Init.call

    assert_equal Sw::Load.new(url: "https://swapi.info/api"), command
  end
end
