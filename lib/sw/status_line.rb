# frozen_string_literal: true

module Sw
  # The line under the title: a status word, if any, then help for the keys that work now.
  module StatusLine
    GlobalKeys = [["r", "Reload"], ["q", "Quit"]].freeze

    # A status word takes no width when absent. Blue is for ephemeral status.
    Word = -> (tui, word, color) {
      [tui.text_span(content: word, style: tui.style(fg: color)), tui.text_span(content: " ")]
    }

    Hotkey = -> (tui, key, label) {
      [tui.text_span(content: key, style: tui.style(modifiers: [:bold, :underlined, :dim])), tui.text_span(content: ": #{label}", style: tui.style(modifiers: [:dim]))]
    }

    View = -> (tui, status: [], keys: []) {
      hotkeys = keys.map { |key, label| Hotkey.call(tui, key, label) }
      tui.paragraph(text: [
        tui.text_line(spans: [*status, *hotkeys.flat_map { |spans| [*spans, tui.text_span(content: "  ")] }.slice(0...-1)]),
      ])
    }
  end
end
