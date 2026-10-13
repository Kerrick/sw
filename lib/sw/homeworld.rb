# frozen_string_literal: true

module Sw
  # Draws a character's homeworld, a View-only part of Selected Character.
  module Homeworld
    LABEL = "Homeworld"

    # Selected Character has no row to spare, so the planet's name shares the border with the label.
    Title = -> (planet, tui) {
      tui.text_line(spans: [tui.text_span(content: "#{LABEL}: "), tui.text_span(content: planet.name.to_s, style: tui.style(modifiers: [:bold]))])
    }

    View = -> (planet, tui) {
      tui.table(
        rows: [
          ["Population:", Values::Span.(planet.population, tui)],
          ["Terrain:", Values::Span.(planet.terrain, tui)],
          ["Climate:", Values::Span.(planet.climate, tui)],
          ["Surface water:", Values::Span.(planet.surface_water, tui, unit: "%")],
          ["Diameter:", Values::Span.(planet.diameter, tui, unit: " km")],
          ["Rotation period:", Values::Span.(planet.rotation_period, tui, unit: " hr")],
          ["Orbital period:", Values::Span.(planet.orbital_period, tui, unit: " d")],
          ["Gravity:", Values::Span.(planet.gravity, tui)],
        ],
        widths: [tui.constraint_length(16), tui.constraint_fill(1)],
        block: tui.block(titles: [{ content: Title.(planet, tui) }], borders: [:all])
      )
    }
  end
end
