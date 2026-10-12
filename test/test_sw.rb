# frozen_string_literal: true

require "test_helper"

class TestSw < Minitest::Test
  include ViewTestHelper
  include ThreeCharacters

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
    with_rendered(Sw::View.call(Sw::Model.new(characters: three_characters), tui)) do
      assert_bold(0, 0)
    end
  end

  def test_the_selected_character_is_named_in_bold
    with_rendered(Sw::View.call(Sw::Model.new(characters: three_characters(selected: luke)), tui)) do
      assert shown_with?("Luke Skywalker", :bold), "Expected Luke Skywalker in bold"
    end
  end

  def test_the_app_starts_with_no_characters_until_the_download_finishes
    model, = Sw::Init.call

    assert_nil model.characters
  end

  def test_the_app_opens_with_the_characters_panel_focused
    model, = Sw::Init.call

    assert_equal :characters, model.focus
  end

  def test_the_characters_border_is_green_when_the_app_opens
    model, = Sw::Init.call

    with_rendered(Sw::View.call(model.with(characters: three_characters), tui)) do
      assert_fg_color(:green, 0, 1)
    end
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

  def test_a_failed_download_shows_a_red_error_status_word
    model, = Sw::Init.call

    with_rendered(Sw::View.call(model.with(failure: "Connection refused"), tui)) do
      status_line = buffer_content.last
      assert_includes status_line, "Error", "Expected the Error status word on the status line"
      assert_fg_color(:red, status_line.index("Error"), buffer_content.size - 1)
    end
  end

  def test_r_is_shown_as_a_hotkey_whether_loading_failed_or_loaded
    loading, = Sw::Init.call
    failed = loading.with(failure: "Connection refused")
    loaded = loading.with(characters: three_characters)

    { loading:, failed:, loaded: }.each do |state, model|
      with_rendered(Sw::View.call(model, tui)) do
        x = buffer_content.last.index("r: ")
        refute_nil x, "Expected r in the key help while #{state}"
        assert_bold(x, buffer_content.size - 1)
        assert_underlined(x, buffer_content.size - 1)
      end
    end
  end

  def test_r_reloads_the_download_after_a_failure
    model, download = Sw::Init.call
    failed = model.with(failure: "Connection refused")

    retried, command = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "r"), failed)

    assert_nil retried.failure
    assert_equal download, command
  end

  def test_r_reloads_the_download_and_keeps_the_characters_on_screen
    loading, download = Sw::Init.call
    characters = three_characters
    loaded = loading.with(characters:)

    reloading, command = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "r"), loaded)

    assert_equal characters, reloading.characters
    assert_equal download, command
  end

  def test_reloading_with_characters_on_screen_shows_the_blue_loading_status_word
    loading, = Sw::Init.call
    loaded = loading.with(characters: three_characters)
    reloading, = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "r"), loaded)

    with_rendered(Sw::View.call(reloading, tui)) do
      status_line = buffer_content.last
      assert_includes status_line, "Loading", "Expected the Loading status word on the status line"
      assert_fg_color(:blue, status_line.index("Loading"), buffer_content.size - 1)
    end
  end

  def test_f5_reloads_the_download_like_r
    model, download = Sw::Init.call
    failed = model.with(failure: "Connection refused")

    reloading, command = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "f5"), failed)

    assert_nil reloading.failure
    assert_equal download, command
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

  def test_the_down_arrow_and_j_move_the_highlight_to_the_next_character
    %w[down j].each do |key|
      model, = Sw::Update.call(RatatuiRuby::Event::Key.new(code: key), Sw::Model.new(characters: three_characters))

      assert_equal han, model.characters.selected, "Expected #{key} to select Han"
    end
  end

  def test_the_up_arrow_and_k_move_the_highlight_to_the_previous_character
    %w[up k].each do |key|
      model, = Sw::Update.call(RatatuiRuby::Event::Key.new(code: key), Sw::Model.new(characters: three_characters(selected: luke)))

      assert_equal han, model.characters.selected, "Expected #{key} to select Han"
    end
  end

  def test_home_and_g_jump_the_highlight_to_the_first_character
    %w[home g].each do |key|
      model, = Sw::Update.call(RatatuiRuby::Event::Key.new(code: key), Sw::Model.new(characters: three_characters(selected: luke)))

      assert_equal ackbar, model.characters.selected, "Expected #{key} to select Ackbar"
    end
  end

  def test_end_and_capital_g_jump_the_highlight_to_the_last_character
    [{ code: "end" }, { code: "G", modifiers: ["shift"] }].each do |key|
      model, = Sw::Update.call(RatatuiRuby::Event::Key.new(**key), Sw::Model.new(characters: three_characters))

      assert_equal luke, model.characters.selected, "Expected #{key} to select Luke"
    end
  end

  def test_the_down_arrow_does_nothing_while_the_download_is_under_way
    loading, = Sw::Init.call

    model, command = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "down"), loading)

    assert_equal loading, model
    assert_nil command
  end

  private def shown_with?(text, *modifiers)
    buffer_content.each_with_index.any? do |line, y|
      x = line.index(text)
      x && (modifiers - Array(get_cell(x, y).modifiers).map(&:to_sym)).empty?
    end
  end
end
