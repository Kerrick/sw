# frozen_string_literal: true

module Sw
  # Draws Values for any panel, dimming the unknown ones.
  module Values
    Span = -> (value, tui) { tui.text_span(content: value.to_s, style: (tui.style(modifiers: [:dim]) if value.unknown?)) }

    Pair = -> (first, second, tui) {
      tui.text_line(spans: [Span.(first, tui), tui.text_span(content: " / "), Span.(second, tui)])
    }
  end
end
