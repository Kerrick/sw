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

  def test_the_title_is_bold
    with_rendered(Sw::View.call(Sw::Model.new(characters: three_characters), tui)) do
      assert_text_style Sw::TITLE, modifiers: [:bold]
    end
  end

  def test_the_selected_character_is_named_in_bold
    with_rendered(Sw::View.call(Sw::Model.new(characters: three_characters(selected: luke)), tui)) do
      assert_text_style "Luke Skywalker", modifiers: [:bold]
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
      x, y = text_position("[2]")
      assert_fg_color(:green, x - 1, y)
    end
  end

  def test_the_status_line_shows_the_list_keys_as_hotkeys_while_the_list_has_focus
    with_rendered(Sw::View.call(Sw::Model.new(characters: three_characters), tui)) do
      %w[k/j g/G].each { |keys| assert_text_style keys, line: -1, modifiers: [:bold, :underlined] }
    end
  end

  def test_the_status_line_hides_the_list_keys_while_search_has_focus
    searching = Sw::Model.new(characters: three_characters, focus: :search)

    with_rendered(Sw::View.call(searching, tui)) do
      %w[k/j g/G].each { |keys| assert_nil text_position(keys), "Expected #{keys} hidden" }
    end
  end

  def test_a_search_for_grogu_still_draws_the_screen
    grogu = Sw::Search::QueryChanged.new(query: "Grogu")
    no_one, = Sw::Characters::Update.call(Rooibos::Message::Routed.new(envelope: :filter, event: grogu), three_characters)

    with_rendered(Sw::View.call(Sw::Model.new(characters: no_one, focus: :search), tui)) do
      refute_nil text_position("Characters")
    end
  end

  def test_the_screen_shows_grogu_typed_into_search
    typing_grogu = Sw::Model.new(characters: three_characters, focus: :search, search: Sw::Search::Init.call.with(query: "Grogu"))

    with_rendered(Sw::View.call(typing_grogu, tui)) do
      refute_nil text_position("Grogu")
    end
  end

  def test_the_screen_tells_the_user_the_download_is_under_way
    model, = Sw::Init.call

    with_rendered(Sw::View.call(model, tui)) do
      between_title_and_key_help = buffer_content[1...-1]
      assert between_title_and_key_help.any? { |line| line.strip != "" }, "Expected a loading box"
      assert_text_style "Loading", line: -1, fg: :blue
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
      assert_text_style "Error", line: -1, fg: :red
    end
  end

  def test_r_is_shown_as_a_hotkey_whether_loading_failed_or_loaded
    loading, = Sw::Init.call
    failed = loading.with(failure: "Connection refused")
    loaded = loading.with(characters: three_characters)

    [loading, failed, loaded].each do |model|
      with_rendered(Sw::View.call(model, tui)) { assert_text_style "r: ", line: -1, modifiers: [:bold, :underlined] }
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
      assert_text_style "Loading", line: -1, fg: :blue
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
      assert_text_style "q: ", line: -1, modifiers: [:bold, :underlined]
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

  def test_slash_and_1_focus_search
    ["/", "1"].each do |key|
      model, = Sw::Update.call(RatatuiRuby::Event::Key.new(code: key), Sw::Model.new(characters: three_characters))

      assert_equal :search, model.focus, "Expected #{key} to focus Search"
    end
  end

  def test_slash_does_nothing_while_the_download_is_under_way
    loading, = Sw::Init.call

    model, command = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "/"), loading)

    assert_equal loading, model
    assert_nil command
  end

  def test_the_down_arrow_leaves_the_highlight_on_ackbar_while_search_has_focus
    searching = Sw::Model.new(characters: three_characters, focus: :search)

    model, = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "down"), searching)

    assert_equal ackbar, model.characters.selected
  end

  def test_enter_after_searching_for_sky_returns_to_the_list_still_showing_the_skywalkers
    skywalkers = three_characters(selected: luke).with(query: "sky")
    searching = Sw::Model.new(characters: skywalkers, focus: :search)

    model, = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "enter"), searching)

    assert_equal :characters, model.focus
    assert_equal skywalkers, model.characters
  end

  def test_tab_from_a_search_for_sky_moves_on_to_the_list_still_showing_the_skywalkers
    skywalkers = three_characters(selected: luke).with(query: "sky")
    searching = Sw::Model.new(characters: skywalkers, focus: :search)

    model, = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "tab"), searching)

    assert_equal :characters, model.focus
    assert_equal skywalkers, model.characters
  end

  def test_tab_from_the_list_wraps_around_to_search
    model, = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "tab"), Sw::Model.new(characters: three_characters))

    assert_equal :search, model.focus
  end

  def test_shift_tab_from_the_list_moves_back_to_search
    [{ code: "back_tab" }, { code: "back_tab", modifiers: ["shift"] }].each do |key|
      model, = Sw::Update.call(RatatuiRuby::Event::Key.new(**key), Sw::Model.new(characters: three_characters))

      assert_equal :search, model.focus, "Expected #{key} to focus Search"
    end
  end

  def test_q_r_digits_slash_and_space_type_into_search_instead_of_acting
    searching = Sw::Model.new(characters: three_characters, focus: :search)

    ["q", "r", "1", "2", "/", " "].each do |key|
      model, = Sw::Update.call(RatatuiRuby::Event::Key.new(code: key), searching)

      assert_equal [:search, key], [model.focus, model.search.query], "Expected #{key.inspect} to type into Search"
    end
  end

  def test_ctrl_c_quits_and_f5_reloads_from_search
    searching = Sw::Model.new(characters: three_characters, focus: :search)

    _, quit = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "c", modifiers: ["ctrl"]), searching)
    _, reload = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "f5"), searching)

    assert_equal Rooibos::Command.exit, quit
    assert_equal Sw::Download.call, reload
  end

  def test_esc_from_a_search_for_sky_lands_on_the_list_with_every_character_back
    skywalkers = three_characters(selected: luke).with(query: "sky")
    searching = Sw::Model.new(characters: skywalkers, focus: :search, search: Sw::Search::Init.call.with(query: "sky"))

    model, = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "esc"), searching)

    assert_equal :characters, model.focus
    assert_equal "", model.search.query
    assert_equal [ackbar, han, luke], model.characters.matches.to_a
  end

  def test_esc_in_the_list_after_searching_for_sky_brings_every_character_back
    skywalkers = three_characters(selected: luke).with(query: "sky")
    browsing = Sw::Model.new(characters: skywalkers, focus: :characters, search: Sw::Search::Init.call.with(query: "sky"))

    model, = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "esc"), browsing)

    assert_equal "", model.search.query
    assert_equal [ackbar, han, luke], model.characters.matches.to_a
  end

  def test_the_down_arrow_does_nothing_while_the_download_is_under_way
    loading, = Sw::Init.call

    model, command = Sw::Update.call(RatatuiRuby::Event::Key.new(code: "down"), loading)

    assert_equal loading, model
    assert_nil command
  end
end
