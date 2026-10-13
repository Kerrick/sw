# frozen_string_literal: true

module Sw
  # Draws vehicles and starships for their panels. Each kind names its class differently, so the panel says which
  # member holds it.
  module Craft
    Widths = -> (tui) { [tui.constraint_length(22), tui.constraint_fill(1)] }

    Heading = -> (craft, class_member, tui) {
      [tui.text_span(content: craft.name.to_s, style: tui.style(modifiers: [:bold])), Values::Span.(craft.public_send(class_member), tui)]
    }

    # One craft's three rows. A Table has no row separators, so each craft is a Table of its own, and every one
    # after the first draws its top border as a rule.
    Entry = -> (craft, class_member, tui, first:) {
      tui.table(
        rows: [
          Heading.(craft, class_member, tui),
          ["Crew / Passengers:", Values::Pair.(craft.crew, craft.passengers, tui)],
          ["Model / Manufacturer:", Values::Pair.(craft.model, craft.manufacturer, tui)],
        ],
        widths: Widths.(tui),
        block: (tui.block(borders: [:top]) unless first)
      )
    }

    Stack = -> (crafts, class_member, tui) {
      tui.layout(
        direction: :vertical,
        constraints: [*crafts.each_with_index.map { |_, index| tui.constraint_length(index.zero? ? 3 : 4) }, tui.constraint_fill(1)],
        children: [*crafts.each_with_index.map { |craft, index| Entry.(craft, class_member, tui, first: index.zero?) }, tui.paragraph(text: "")]
      )
    }
  end
end
