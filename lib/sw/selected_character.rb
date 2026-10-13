# frozen_string_literal: true

module Sw
  # The panel beside the list, titled with the highlighted character's name.
  module SelectedCharacter
    View = -> (character, tui) {
      return tui.block(borders: [:all]) unless character

      spacer = tui.paragraph(text: "")
      tui.block(
        title: character.name,
        title_style: tui.style(modifiers: [:bold]),
        borders: [:all],
        children: [
          tui.layout(
            direction: :horizontal,
            constraints: [tui.constraint_fill(1), tui.constraint_fill(1), tui.constraint_fill(1)],
            children: [spacer, SpeciesBox::View.(character.species.first, tui), HomeworldBox::View.(character.homeworld, tui)]
          ),
        ]
      )
    }
  end
end
