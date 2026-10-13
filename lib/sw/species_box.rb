# frozen_string_literal: true

module Sw
  # Draws a character's species, a View-only part of Selected Character.
  module SpeciesBox
    LABEL = "Species"

    # Selected Character has no row to spare, so the species' name shares the border with the label.
    Title = -> (species, tui) {
      tui.text_line(spans: [tui.text_span(content: "#{LABEL}: "), tui.text_span(content: species.name.to_s, style: tui.style(modifiers: [:bold]))])
    }

    # What the box says for a character the data gives no species.
    UNKNOWN = "unknown"

    View = -> (species, tui) {
      return tui.block(title: LABEL, borders: [:all], children: [Empty::View.(UNKNOWN, tui)]) unless species

      tui.table(
        rows: [
          ["Classification:", Values::Span.(species.classification, tui)],
          ["Designation:", Values::Span.(species.designation, tui)],
          ["Average height:", Values::Span.(species.average_height, tui, unit: " cm")],
          ["Average lifespan:", Values::Span.(species.average_lifespan, tui, unit: " yr")],
          ["Language:", Values::Span.(species.language, tui)],
        ],
        widths: [tui.constraint_length(17), tui.constraint_fill(1)],
        block: tui.block(titles: [{ content: Title.(species, tui) }], borders: [:all])
      )
    }
  end
end
