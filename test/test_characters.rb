# frozen_string_literal: true

require "test_helper"

class TestCharacters < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_ackbar_is_listed_before_luke_skywalker
    luke = Sw::Character.new(name: "Luke Skywalker")
    ackbar = Sw::Character.new(name: "Ackbar")

    with_test_terminal do
      RatatuiRuby.draw do |frame|
        frame.render_widget(Sw::Characters::View.call(Sw::Collection.new([luke, ackbar]), RatatuiRuby::TUI.new), frame.area)
      end

      assert_operator row_of("Ackbar"), :<, row_of("Luke Skywalker")
    end
  end

  private def row_of(text)
    buffer_content.index { |line| line.include?(text) }
  end
end
