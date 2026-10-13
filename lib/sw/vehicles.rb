# frozen_string_literal: true

module Sw
  # The panel that shows the vehicles its screen's subject is linked to.
  module Vehicles
    # What the panel says when its subject is linked to no vehicles.
    EMPTY = "No vehicles"

    # One vehicle's three rows. A Table has no row separators, so each vehicle is a Table of its own, and every
    # one after the first draws its top border as a rule.
    Vehicle = -> (vehicle, tui, first:) {
      tui.table(
        rows: [
          [tui.text_span(content: vehicle.name.to_s, style: tui.style(modifiers: [:bold])), Values::Span.(vehicle.vehicle_class, tui)],
          ["Crew / Passengers:", Values::Pair.(vehicle.crew, vehicle.passengers, tui)],
          ["Model / Manufacturer:", Values::Pair.(vehicle.model, vehicle.manufacturer, tui)],
        ],
        widths: [tui.constraint_length(22), tui.constraint_fill(1)],
        block: (tui.block(borders: [:top]) unless first)
      )
    }

    Stack = -> (vehicles, tui) {
      tui.layout(
        direction: :vertical,
        constraints: [*vehicles.each_with_index.map { |_, index| tui.constraint_length(index.zero? ? 3 : 4) }, tui.constraint_fill(1)],
        children: [*vehicles.each_with_index.map { |vehicle, index| Vehicle.call(vehicle, tui, first: index.zero?) }, tui.paragraph(text: "")]
      )
    }

    Empty = -> (tui) {
      spacer = tui.paragraph(text: "")
      tui.layout(
        direction: :vertical,
        constraints: [tui.constraint_fill(1), tui.constraint_length(1), tui.constraint_fill(1)],
        children: [spacer, tui.paragraph(text: EMPTY, alignment: :center, style: tui.style(modifiers: [:dim])), spacer]
      )
    }

    # No subject arrives when no character matches a search.
    View = -> (vehicles, tui) {
      return tui.block(title: "Vehicles", borders: [:all]) unless vehicles

      tui.block(title: "Vehicles", borders: [:all], children: [vehicles.any? ? Stack.(vehicles, tui) : Empty.(tui)])
    }
  end
end
