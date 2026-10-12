# frozen_string_literal: true

require "test_helper"

class TestCharacters < Minitest::Test
  include ViewTestHelper
  include ThreeCharacters

  def test_init_selects_ackbar_the_first_alphabetically
    assert_equal ackbar, three_characters.selected
  end

  def test_ackbar_is_listed_before_luke_skywalker
    with_rendered(Sw::Characters::View.call(three_characters, tui)) do
      assert_operator row_of("Ackbar"), :<, row_of("Luke Skywalker")
    end
  end

  def test_the_selected_character_is_highlighted
    with_rendered(Sw::Characters::View.call(three_characters(selected: luke), tui)) do
      assert_reversed(1, row_of("Luke Skywalker"))
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

  private def moved(intent, model)
    model, = Sw::Characters::Update.call(Rooibos::Message::Routed.new(envelope: intent, event: nil), model)
    model
  end

  private def row_of(text)
    buffer_content.index { |line| line.include?(text) }
  end
end
