# frozen_string_literal: true

module Sw
  # The title over the status line, with Search beside them once there is data to search.
  module Header
    TITLE = "Star Wars Character Datapad"

    Title = -> (tui) { tui.paragraph(text: TITLE, style: tui.style(modifiers: [:bold])) }

    View = -> (status_line, tui, search: nil) {
      title_and_status = tui.layout(
        direction: :vertical,
        constraints: [
          tui.constraint_length(1),
          tui.constraint_fill(1),
          tui.constraint_length(1),
        ],
        children: [
          Title.call(tui),
          tui.paragraph(text: ""),
          status_line,
        ]
      )
      return title_and_status unless search

      tui.layout(
        direction: :horizontal,
        constraints: [tui.constraint_fill(1), tui.constraint_length(ListWidth)],
        children: [title_and_status, search]
      )
    }
  end
end
