# frozen_string_literal: true

module Sw
  # Draws a character's homeworld, a View-only part of Selected Character.
  module HomeworldBox
    LABEL = "Homeworld"

    # Selected Character has no row to spare, so the planet's name shares the border with the label.
    Title = -> (planet, tui) {
      tui.text_line(
        spans: [
          tui.text_span(content: "#{LABEL}: "),
          tui.text_span(
            content: planet.name.to_s,
            style: tui.style(modifiers: [:bold])
          ),
        ]
      )
    }

    # What the box says for a planet the data names "unknown", which stands for no planet at all.
    UNKNOWN = "unknown"

    View = -> (planet, tui) {
      if planet.name.unknown?
        return tui.block(
          title: LABEL,
          borders: [:all],
          children: [
            Empty::View.call(UNKNOWN, tui),
          ]
        )
      end

      tui.table(
        rows: [
          ["Population:", Values::Span.call(planet.population, tui)],
          ["Terrain:", Values::Span.call(planet.terrain, tui)],
          ["Climate:", Values::Span.call(planet.climate, tui)],
          ["Surface water:", Values::Span.call(planet.surface_water, tui, unit: "%")],
          ["Diameter:", Values::Span.call(planet.diameter, tui, unit: " km")],
          ["Rotation period:", Values::Span.call(planet.rotation_period, tui, unit: " hr")],
          ["Orbital period:", Values::Span.call(planet.orbital_period, tui, unit: " d")],
          ["Gravity:", Values::Span.call(planet.gravity, tui)],
        ],
        widths: [tui.constraint_length(16), tui.constraint_fill(1)],
        block: tui.block(
          titles: [{ content: Title.call(planet, tui) }],
          borders: [:all]
        )
      )
    }
  end
end
