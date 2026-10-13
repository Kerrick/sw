# frozen_string_literal: true

module Sw
  # The panel that shows every film, lit for the ones its screen's subject appears in.
  module Films
    Column = -> (film, lit, tui) {
      tui.paragraph(
        text: [
          tui.text_line(
            spans: [
              tui.text_span(
                content: film.title.to_s,
                style: tui.style(modifiers: lit ? [:bold] : [:bold, :dim])
              ),
            ]
          ),
          tui.text_line(
            spans: [
              tui.text_span(
                content: film.episode,
                style: tui.style(modifiers: lit ? [] : [:dim])
              ),
            ]
          ),
        ],
        alignment: :center
      )
    }

    # No subject arrives when no character matches a search.
    View = -> (films, appearing_in, tui) {
      return tui.block(title: "Films", borders: [:all]) unless appearing_in

      films = films.sort_by(&:episode_id)
      tui.block(
        title: "Films",
        borders: [:all],
        children: [
          tui.layout(
            direction: :horizontal,
            constraints: films.map { tui.constraint_fill(1) },
            children: films.map { |film| Column.call(film, appearing_in.include?(film), tui) }
          ),
        ]
      )
    }
  end
end
