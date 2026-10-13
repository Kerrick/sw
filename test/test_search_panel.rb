# frozen_string_literal: true

require "test_helper"

class TestSearchPanel < Minitest::Test
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
