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
      assert shown_with?("Luke Skywalker", :bold), "Expected Luke Skywalker in bold"
    end
  end

  def test_the_app_starts_with_no_characters_until_the_download_finishes
    model, = Sw::Init.call

    assert_nil model.characters
  end

  def test_the_screen_tells_the_user_the_download_is_under_way
    model, = Sw::Init.call

    with_rendered(Sw::View.call(model, tui)) do
      between_title_and_key_help = buffer_content[1...-1]
      assert between_title_and_key_help.any? { |line| line.strip != "" }, "Expected a loading box"
      status_line = buffer_content.last
      assert_includes status_line, "Loading", "Expected the Loading status word on the status line"
      assert_fg_color(:blue, status_line.index("Loading"), buffer_content.size - 1)
    end
  end

  def test_the_app_knows_why_the_download_failed
    model, = Sw::Init.call

    updated, = Sw::Update.call(Sw::Load::Failed.new(reason: "Connection refused"), model)

    assert_equal "Connection refused", updated.failure
  end

  def test_the_screen_shows_why_the_download_failed
    model, = Sw::Init.call

    with_rendered(Sw::View.call(model.with(failure: "Connection refused"), tui)) do
      assert_includes buffer_content.join("\n"), "Connection refused"
    end
  end

  def test_q_quits
    model, = Sw::Init.call

    _, command = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "q"), model)

    assert_equal Rooibos::Command.exit, command
  end

  def test_q_is_shown_as_a_hotkey
    model, = Sw::Init.call

    with_rendered(Sw::View.call(model, tui)) do
      assert shown_with?("q", :bold, :underlined), "Expected q styled as a hotkey"
    end
  end

  private def shown_with?(text, *modifiers)
    buffer_content.each_with_index.any? do |line, y|
      x = line.index(text)
      x && (modifiers - Array(get_cell(x, y).modifiers).map(&:to_sym)).empty?
    end
  end
end
