# frozen_string_literal: true

require "test_helper"

class TestSearchPanel < Minitest::Test
  include ViewTestHelper

  def test_a_search_for_grogu_shows_grogu
    searched_for_grogu = Sw::Search::Init.call.with(query: "Grogu")

    with_rendered(Sw::Search::View.call(searched_for_grogu, tui, focused: true, number: 1)) do
      refute_nil text_position("Grogu")
    end
  end

  def test_a_blinking_cursor_follows_grogu_while_search_has_focus
    searched_for_grogu = Sw::Search::Init.call.with(query: "Grogu")

    with_rendered(Sw::Search::View.call(searched_for_grogu, tui, focused: true, number: 1)) do
      x, y = text_position("Grogu")
      assert_cell_style(x + "Grogu".length, y, symbol: "_", modifiers: [:slow_blink])
    end
  end

  def test_no_cursor_follows_grogu_while_the_list_has_focus
    searched_for_grogu = Sw::Search::Init.call.with(query: "Grogu")

    with_rendered(Sw::Search::View.call(searched_for_grogu, tui, focused: false, number: 1)) do
      assert_nil text_position("Grogu_")
    end
  end

  def test_search_is_titled_with_its_number_1
    with_rendered(Sw::Search::View.call(Sw::Search::Init.call, tui, focused: true, number: 1)) do
      refute_nil text_position("[1]")
    end
  end

  def test_the_border_is_green_only_while_search_has_focus
    with_rendered(Sw::Search::View.call(Sw::Search::Init.call, tui, focused: true, number: 1)) do
      assert_fg_color(:green, 0, 0)
    end
    with_rendered(Sw::Search::View.call(Sw::Search::Init.call, tui, focused: false, number: 1)) do
      refute_equal :green, get_cell(0, 0).fg
    end
  end

  def test_typing_s_into_an_empty_search_makes_the_query_s
    model, = Sw::Search::Update.call(RatatuiRuby::Event::Key.new(code: "s"), Sw::Search::Init.call)

    assert_equal "s", model.query
  end

  def test_typing_s_tells_the_screen_the_query_is_now_s
    _, command = Sw::Search::Update.call(RatatuiRuby::Event::Key.new(code: "s"), Sw::Search::Init.call)

    assert_equal Rooibos::Command.bubble(Sw::Search::QueryChanged.new(query: "s")), command
  end

  def test_typing_k_after_s_makes_the_query_sk
    after_s = Sw::Search::Init.call.with(query: "s")

    model, = Sw::Search::Update.call(RatatuiRuby::Event::Key.new(code: "k"), after_s)

    assert_equal "sk", model.query
  end

  def test_ctrl_u_after_sky_clears_the_query
    after_sky = Sw::Search::Init.call.with(query: "sky")

    model, = Sw::Search::Update.call(RatatuiRuby::Event::Key.new(code: "u", modifiers: ["ctrl"]), after_sky)

    assert_equal "", model.query
  end

  def test_ctrl_u_after_sky_tells_the_screen_the_query_is_empty
    after_sky = Sw::Search::Init.call.with(query: "sky")

    _, command = Sw::Search::Update.call(RatatuiRuby::Event::Key.new(code: "u", modifiers: ["ctrl"]), after_sky)

    assert_equal Rooibos::Command.bubble(Sw::Search::QueryChanged.new(query: "")), command
  end

  def test_clearing_sky_empties_the_query_and_tells_the_screen
    after_sky = Sw::Search::Init.call.with(query: "sky")

    model, command = Sw::Search::Update.call(Rooibos::Message::Routed.new(envelope: :clear, event: nil), after_sky)

    assert_equal "", model.query
    assert_equal Rooibos::Command.bubble(Sw::Search::QueryChanged.new(query: "")), command
  end

  def test_pasting_skywalker_into_an_empty_search_makes_the_query_skywalker
    model, command = Sw::Search::Update.call(RatatuiRuby::Event::Paste.new(content: "Skywalker"), Sw::Search::Init.call)

    assert_equal "Skywalker", model.query
    assert_equal Rooibos::Command.bubble(Sw::Search::QueryChanged.new(query: "Skywalker")), command
  end

  def test_pasting_yoda_with_a_trailing_newline_makes_the_query_yoda
    yoda_copied_with_its_line_break = "Yoda\n"

    model, = Sw::Search::Update.call(RatatuiRuby::Event::Paste.new(content: yoda_copied_with_its_line_break), Sw::Search::Init.call)

    assert_equal "Yoda", model.query
  end

  def test_ctrl_a_and_alt_b_leave_sky_as_it_was
    after_sky = Sw::Search::Init.call.with(query: "sky")

    [{ code: "a", modifiers: ["ctrl"] }, { code: "b", modifiers: ["alt"] }].each do |chord|
      model, = Sw::Search::Update.call(RatatuiRuby::Event::Key.new(**chord), after_sky)

      assert_equal "sky", model.query, "Expected #{chord} not to type"
    end
  end

  def test_backspace_in_an_empty_search_leaves_the_query_empty
    model, = Sw::Search::Update.call(RatatuiRuby::Event::Key.new(code: "backspace"), Sw::Search::Init.call)

    assert_equal "", model.query
  end

  def test_backspace_after_sky_tells_the_screen_the_query_is_now_sk
    after_sky = Sw::Search::Init.call.with(query: "sky")

    _, command = Sw::Search::Update.call(RatatuiRuby::Event::Key.new(code: "backspace"), after_sky)

    assert_equal Rooibos::Command.bubble(Sw::Search::QueryChanged.new(query: "sk")), command
  end

  def test_backspace_after_sky_makes_the_query_sk
    after_sky = Sw::Search::Init.call.with(query: "sky")

    model, = Sw::Search::Update.call(RatatuiRuby::Event::Key.new(code: "backspace"), after_sky)

    assert_equal "sk", model.query
  end
end
