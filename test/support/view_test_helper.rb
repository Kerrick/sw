# frozen_string_literal: true

# Renders a View's widget into a test terminal, for asserting on the screen.
module ViewTestHelper
  include RatatuiRuby::TestHelper

  private def tui = RatatuiRuby::TUI.new

  private def with_rendered(widget)
    with_test_terminal do
      RatatuiRuby.draw { |frame| frame.render_widget(widget, frame.area) }
      yield
    end
  end

  # Where text first appears on screen, as [x, y], or nil. Only lines that also show on_line_with count,
  # and only the one line when line is given (negative counts from the bottom).
  private def text_position(text, on_line_with: text, line: nil)
    rows = buffer_content.each_with_index.to_a
    rows = [rows.fetch(line)] if line
    _, y = rows.find { |content, _| content.include?(text) && content.include?(on_line_with) }
    y && [buffer_content[y].index(text), y]
  end

  # Asserts the style of the first cell of text, found as text_position finds it, with assert_cell_style's attributes.
  # Pass modifiers as Symbols, which cells hold at runtime, though RatatuiRuby's cell.rbs says Strings.
  private def assert_text_style(text, on_line_with: text, line: nil, **expected_attributes)
    x, y = text_position(text, on_line_with:, line:)
    refute_nil y, "Expected #{text.inspect} on screen#{" on a line with #{on_line_with.inspect}" unless on_line_with == text}"
    assert_cell_style(x, y, **expected_attributes)
  end
end
