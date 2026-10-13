# frozen_string_literal: true

module Sw
  # The panel that shows the starships its screen's subject is linked to.
  module Starships
    # What the panel says when its subject is linked to no starships.
    EMPTY = "No starships"

    # One starship's three rows. A Table has no row separators, so each starship is a Table of its own, and every
    # one after the first draws its top border as a rule.
    Starship = -> (starship, tui, first:) {
      tui.table(
        rows: [
          [tui.text_span(content: starship.name.to_s, style: tui.style(modifiers: [:bold])), Values::Span.(starship.starship_class, tui)],
          ["Crew / Passengers:", Values::Pair.(starship.crew, starship.passengers, tui)],
          ["Model / Manufacturer:", Values::Pair.(starship.model, starship.manufacturer, tui)],
        ],
        widths: [tui.constraint_length(22), tui.constraint_fill(1)],
        block: (tui.block(borders: [:top]) unless first)
      )
    }

    Stack = -> (starships, tui) {
      tui.layout(
        direction: :vertical,
        constraints: [*starships.each_with_index.map { |_, index| tui.constraint_length(index.zero? ? 3 : 4) }, tui.constraint_fill(1)],
        children: [*starships.each_with_index.map { |starship, index| Starship.call(starship, tui, first: index.zero?) }, tui.paragraph(text: "")]
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
    View = -> (starships, tui) {
      return tui.block(title: "Starships", borders: [:all]) unless starships

      tui.block(title: "Starships", borders: [:all], children: [starships.any? ? Stack.(starships, tui) : Empty.(tui)])
    }
  end
end
