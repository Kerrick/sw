# frozen_string_literal: true

module Sw
  # The panel that lists every character by name.
  module Characters
    View = -> (characters, tui) {
      tui.list(
        items: characters.map(&:name).sort,
        block: tui.block(title: "Characters", borders: [:all])
      )
    }
  end
end
