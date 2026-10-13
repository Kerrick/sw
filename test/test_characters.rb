# frozen_string_literal: true

require "test_helper"

class TestCharacters < Minitest::Test
  include ViewTestHelper
  include ThreeCharacters

  def test_init_selects_ackbar_the_first_alphabetically
    assert_equal ackbar, three_characters.selected
  end

  def test_ackbar_is_listed_before_luke_skywalker
    with_rendered(Sw::Characters::View.call(three_characters, tui, number: 2)) do
      assert_operator text_position("Ackbar").last, :<, text_position("Luke Skywalker").last
    end
  end

  def test_the_selected_character_is_highlighted
    with_rendered(Sw::Characters::View.call(three_characters(selected: luke), tui, number: 2)) do
      assert_text_style "Luke Skywalker", modifiers: [:reversed]
    end
  end

  def test_the_list_is_titled_with_its_number_2
    with_rendered(Sw::Characters::View.call(three_characters, tui, number: 2)) do
      refute_nil text_position("[2]")
    end
  end

  def test_the_border_is_green_only_while_the_list_has_focus
    with_rendered(Sw::Characters::View.call(three_characters, tui, number: 2, focused: true)) do
      assert_fg_color(:green, 0, 0)
    end
    with_rendered(Sw::Characters::View.call(three_characters, tui, number: 2, focused: false)) do
      refute_equal :green, get_cell(0, 0).fg
    end
  end

  def test_moving_down_selects_the_next_character
    assert_equal han, moved(:move_down, three_characters).selected
  end

  def test_moving_down_from_the_last_character_stays_on_the_last_character
    assert_equal luke, moved(:move_down, three_characters(selected: luke)).selected
  end

  def test_moving_up_selects_the_previous_character
    assert_equal han, moved(:move_up, three_characters(selected: luke)).selected
  end

  def test_moving_up_from_ackbar_stays_on_ackbar
    assert_equal ackbar, moved(:move_up, three_characters).selected
  end

  def test_jumping_to_the_first_character_skips_the_ones_between
    assert_equal ackbar, moved(:move_first, three_characters(selected: luke)).selected
  end

  def test_jumping_to_the_last_character_skips_the_ones_between
    assert_equal luke, moved(:move_last, three_characters).selected
  end

  def test_filtering_by_sky_matches_only_luke_skywalker
    sky = Sw::Search::QueryChanged.new(query: "sky")

    filtered, = Sw::Characters::Update.call(Rooibos::Message::Routed.new(envelope: :filter, event: sky), three_characters)

    assert_equal [luke], filtered.matches.to_a
  end

  def test_a_search_for_sky_moves_the_highlight_from_ackbar_to_luke
    sky = Sw::Search::QueryChanged.new(query: "sky")

    filtered, = Sw::Characters::Update.call(Rooibos::Message::Routed.new(envelope: :filter, event: sky), three_characters)

    assert_equal luke, filtered.selected
  end

  def test_a_search_for_s_keeps_the_highlight_on_luke_though_han_solo_comes_first
    s = Sw::Search::QueryChanged.new(query: "s")

    filtered, = Sw::Characters::Update.call(Rooibos::Message::Routed.new(envelope: :filter, event: s), three_characters(selected: luke))

    assert_equal luke, filtered.selected
  end

  def test_after_a_search_for_k_moving_down_from_ackbar_skips_han_solo_to_luke
    k = Sw::Search::QueryChanged.new(query: "k")
    ackbar_and_luke, = Sw::Characters::Update.call(Rooibos::Message::Routed.new(envelope: :filter, event: k), three_characters)

    assert_equal luke, moved(:move_down, ackbar_and_luke).selected
  end

  def test_after_a_search_for_s_jumping_to_the_first_character_lands_on_han_solo_not_ackbar
    s = Sw::Search::QueryChanged.new(query: "s")
    han_and_luke, = Sw::Characters::Update.call(Rooibos::Message::Routed.new(envelope: :filter, event: s), three_characters(selected: luke))

    assert_equal han, moved(:move_first, han_and_luke).selected
  end

  def test_after_a_search_for_o_jumping_to_the_last_character_stays_on_han_solo_not_luke
    o = Sw::Search::QueryChanged.new(query: "o")
    only_han, = Sw::Characters::Update.call(Rooibos::Message::Routed.new(envelope: :filter, event: o), three_characters)

    assert_equal han, moved(:move_last, only_han).selected
  end

  def test_moving_down_or_up_after_a_search_for_grogu_highlights_no_one
    grogu = Sw::Search::QueryChanged.new(query: "Grogu")
    no_one, = Sw::Characters::Update.call(Rooibos::Message::Routed.new(envelope: :filter, event: grogu), three_characters)

    %i[move_down move_up].each { |intent| assert_nil moved(intent, no_one).selected, "Expected #{intent} to highlight no one" }
  end

  def test_a_search_for_sky_lists_luke_skywalker_without_ackbar
    searched_for_sky = three_characters(selected: luke).with(query: "sky")

    with_rendered(Sw::Characters::View.call(searched_for_sky, tui, number: 2)) do
      refute_nil text_position("Luke Skywalker")
      assert_nil text_position("Ackbar")
    end
  end

  def test_a_search_for_grogu_says_dimly_that_nothing_matches_grogu_in_dim_yellow
    grogu = Sw::Search::QueryChanged.new(query: "Grogu")
    no_one, = Sw::Characters::Update.call(Rooibos::Message::Routed.new(envelope: :filter, event: grogu), three_characters)

    with_rendered(Sw::Characters::View.call(no_one, tui, number: 2)) do
      assert_text_style Sw::Characters::EMPTY, modifiers: [:dim]
      assert_text_style "Grogu", fg: :yellow, modifiers: [:dim]
    end
  end

  private def moved(intent, model)
    model, = Sw::Characters::Update.call(Rooibos::Message::Routed.new(envelope: intent, event: nil), model)
    model
  end
end
