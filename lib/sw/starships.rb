# frozen_string_literal: true

module Sw
  # The panel for the starships a character pilots. It has no content yet.
  module Starships
    View = -> (tui) { tui.block(title: "Starships", borders: [:all]) }
  end
end
