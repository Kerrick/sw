# frozen_string_literal: true

module Sw
  # The panel that shows the vehicles a record links to, as the mockup does.
  module Vehicles
    View = -> (vehicles, tui) {
      tui.paragraph(
        text: vehicles.map { |vehicle| tui.text_line(spans: [tui.text_span(content: vehicle.name, style: tui.style(modifiers: [:bold]))]) },
        block: tui.block(title: "Vehicles", borders: [:all])
      )
    }
  end
end
