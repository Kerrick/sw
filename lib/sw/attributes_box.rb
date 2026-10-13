# frozen_string_literal: true

module Sw
  # Draws a character's attributes, a View-only part of Selected Character.
  module AttributesBox
    LABEL = "Attributes"

    View = -> (character, tui) {
      tui.table(
        rows: [
          ["Birth year:", Values::Span.call(character.birth_year, tui)],
          ["Gender:", Values::Span.call(character.gender, tui)],
          ["Height:", Values::Span.call(character.height, tui, unit: " cm")],
          ["Mass:", Values::Span.call(character.mass, tui, unit: " kg")],
          ["Eye color:", Values::Span.call(character.eye_color, tui)],
          ["Hair color:", Values::Span.call(character.hair_color, tui)],
          ["Skin color:", Values::Span.call(character.skin_color, tui)],
        ],
        widths: [tui.constraint_length(11), tui.constraint_fill(1)],
        block: tui.block(title: LABEL, borders: [:all])
      )
    }
  end
end
