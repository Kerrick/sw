# frozen_string_literal: true

module Sw
  # Draws Values for any panel, dimming the unknown ones.
  module Values
    # A unit follows only a known value: "unknown km" would claim to know the unit of nothing.
    Span = -> (value, tui, unit: "") {
      return tui.text_span(content: value.to_s, style: tui.style(modifiers: [:dim])) if value.unknown?

      tui.text_span(content: "#{value}#{unit}")
    }

    Pair = -> (first, second, tui) {
      tui.text_line(spans: [Span.(first, tui), tui.text_span(content: " / "), Span.(second, tui)])
    }
  end
end
