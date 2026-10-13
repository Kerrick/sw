# frozen_string_literal: true

module Sw
  # The panel that shows the starships its screen's subject is linked to.
  module Starships
    # What the panel says when its subject is linked to no starships.
    EMPTY = "No starships"

    # No subject arrives when no character matches a search.
    View = -> (starships, tui) {
      return tui.block(title: "Starships", borders: [:all]) unless starships

      tui.block(
        title: "Starships",
        borders: [:all],
        children: [
          starships.any? ? Craft::Stack.call(starships, :starship_class, tui) : Empty::View.call(EMPTY, tui),
        ]
      )
    }
  end
end
