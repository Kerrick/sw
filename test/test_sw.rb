# frozen_string_literal: true

require "test_helper"

class TestSw < Minitest::Test
  include ViewTestHelper

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

  def test_the_top_line_is_a_bold_title
    model = Sw::Model.new(characters: Sw::Characters::Init.(characters: Sw::Collection.new([])))

    with_rendered(Sw::View.call(model, tui)) do
      assert_bold(0, 0)
    end
  end

  def test_the_selected_character_is_named_in_bold
    luke = Sw::Character.new(name: "Luke Skywalker")
    ackbar = Sw::Character.new(name: "Ackbar")
    characters = Sw::Characters::Init.(characters: Sw::Collection.new([luke, ackbar])).with(selected: luke)

    with_rendered(Sw::View.call(Sw::Model.new(characters:), tui)) do
      assert shown_in_bold?("Luke Skywalker"), "Expected Luke Skywalker in bold"
    end
  end

  private def shown_in_bold?(text)
    buffer_content.each_with_index.any? do |line, y|
      x = line.index(text)
      x && get_cell(x, y).modifiers&.map(&:to_sym)&.include?(:bold)
    end
  end
end
