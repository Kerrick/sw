# frozen_string_literal: true

module Sw
  # The panel that shows the vehicles its screen's subject is linked to.
  module Vehicles
    # What the panel says when its subject is linked to no vehicles.
    EMPTY = "No vehicles"

    # No subject arrives when no character matches a search.
    View = -> (vehicles, tui) {
      return tui.block(title: "Vehicles", borders: [:all]) unless vehicles

      tui.block(
        title: "Vehicles",
        borders: [:all],
        children: [vehicles.any? ? Craft::Stack.(vehicles, :vehicle_class, tui) : Empty::View.(EMPTY, tui)]
      )
    }
  end
end
