# frozen_string_literal: true

module Sw
  # Draws Values for any panel, dimming the ones that are unknown or don't apply.
  module Values
    # A unit follows only a number: "unknown km" would claim to know the unit of nothing, and a droid's "indefinite"
    # lifespan counts no years.
    Span = -> (value, tui, unit: "") {
      if value.unknown? || value.not_applicable?
        return tui.text_span(
          content: value.to_s,
          style: tui.style(modifiers: [:dim])
        )
      end
      return tui.text_span(content: value.to_s) unless value.numeric?

      tui.text_span(content: "#{value}#{unit}")
    }

    Pair = -> (first, second, tui) {
      tui.text_line(
        spans: [
          Span.(first, tui),
          tui.text_span(content: " / "),
          Span.(second, tui),
        ]
      )
    }
  end
end
