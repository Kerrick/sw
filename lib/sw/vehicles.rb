# frozen_string_literal: true

module Sw
  # The panel that shows the vehicles a record links to, as the mockup does.
  module Vehicles
    # A value as text, dimmed when the data doesn't know it.
    ValueSpan = -> (value, tui) { tui.text_span(content: value.to_s, style: (tui.style(modifiers: [:dim]) if value.unknown?)) }

    # One vehicle's three rows. Every vehicle after the first has a rule above it.
    Vehicle = -> (vehicle, tui, first:) {
      tui.table(
        rows: [
          [tui.text_span(content: vehicle.name.to_s, style: tui.style(modifiers: [:bold])), vehicle.vehicle_class],
          ["Crew / Passengers:", tui.text_line(spans: [ValueSpan.(vehicle.crew, tui), tui.text_span(content: " / "), ValueSpan.(vehicle.passengers, tui)])],
          ["Model / Manufacturer:", "#{vehicle.model} / #{vehicle.manufacturer}"],
        ],
        widths: [tui.constraint_length(22), tui.constraint_fill(1)],
        block: (tui.block(borders: [:top]) unless first)
      )
    }

    View = -> (vehicles, tui) {
      tui.block(
        title: "Vehicles",
        borders: [:all],
        children: [
          tui.layout(
            direction: :vertical,
            constraints: [*vehicles.each_with_index.map { |_, index| tui.constraint_length(index.zero? ? 3 : 4) }, tui.constraint_fill(1)],
            children: [*vehicles.each_with_index.map { |vehicle, index| Vehicle.call(vehicle, tui, first: index.zero?) }, tui.paragraph(text: "")]
          ),
        ]
      )
    }
  end
end
