# frozen_string_literal: true

require "test_helper"

class TestCharacters < Minitest::Test
  include ViewTestHelper

  def setup
    @luke = Sw::Character.new(name: "Luke Skywalker")
    @ackbar = Sw::Character.new(name: "Ackbar")
  end

  def test_init_selects_ackbar_the_first_alphabetically
    model = Sw::Characters::Init.(characters: Sw::Collection.new([@luke, @ackbar]))

    assert_equal @ackbar, model.selected
  end

  def test_ackbar_is_listed_before_luke_skywalker
    model = Sw::Characters::Init.(characters: Sw::Collection.new([@luke, @ackbar]))

    with_rendered(Sw::Characters::View.call(model, tui)) do
      assert_operator row_of("Ackbar"), :<, row_of("Luke Skywalker")
    end
  end

  def test_the_selected_character_is_highlighted
    model = Sw::Characters::Init.(characters: Sw::Collection.new([@luke, @ackbar])).with(selected: @luke)

    with_rendered(Sw::Characters::View.call(model, tui)) do
      assert_reversed(1, row_of("Luke Skywalker"))
    end
  end

  private def row_of(text)
    buffer_content.index { |line| line.include?(text) }
  end
end
