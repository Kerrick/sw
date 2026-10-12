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
end
