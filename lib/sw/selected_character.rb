# frozen_string_literal: true

module Sw
  # The panel beside the list, titled with the highlighted character's name, or untitled when no character matches.
  module SelectedCharacter
    View = -> (character, tui) {
      return tui.block(borders: [:all]) unless character

      tui.block(title: character.name, title_style: tui.style(modifiers: [:bold]), borders: [:all])
    }
  end
end
