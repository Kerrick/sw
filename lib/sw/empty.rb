# frozen_string_literal: true

module Sw
  # Draws a panel's dimmed message, centered, for when it has nothing to show.
  module Empty
    View = -> (text, tui) {
      spacer = tui.paragraph(text: "")
      tui.layout(
        direction: :vertical,
        constraints: [tui.constraint_fill(1), tui.constraint_length(1), tui.constraint_fill(1)],
        children: [spacer, tui.paragraph(text:, alignment: :center, style: tui.style(modifiers: [:dim])), spacer]
      )
    }
  end
end
